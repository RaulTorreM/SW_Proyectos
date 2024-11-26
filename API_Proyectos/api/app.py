from flask import Flask, request, jsonify
import mysql.connector
import joblib
import pandas as pd
import numpy as np
from flask_cors import CORS 
import folium
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
import os
from matplotlib import cm, colors

# Inicializar Flask
app = Flask(__name__, static_folder='static')
CORS(app)

# Conexión a MySQL
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",       # Cambia esto según tu configuración
        password="",       # Cambia esto según tu configuración
        database="db_proyecto_anemia"  # Cambia esto según tu base de datos
    )

# Crear conexión global
db_connection = get_db_connection()

# Cargar modelos entrenados
modelo_arbol = joblib.load('modelo_arbol_decision.pkl')

# API para predicción de anemia
@app.route('/api/predict', methods=['POST'])
def predict():
    try:
        data = request.json

        # Obtener los datos necesarios del cuerpo de la solicitud
        dni_usuario = data['dni_usuario']
        nombres = data['nombres']
        sexo = data['sexo']
        region = data['region']
        edad = float(data['edad'])
        peso = float(data['peso'])
        talla = float(data['talla'])
        hemoglobina = float(data['hemoglobina'])

        # Preparar los datos para el modelo
        input_data = pd.DataFrame({
            'HW1': [edad],
            'HW2': [peso],
            'HW3': [talla],
            'HW53': [hemoglobina]
        })

        # Realizar la predicción
        nivel_anemia = modelo_arbol.predict(input_data)[0]

        # Obtener la descripción y recomendación del nivel de anemia
        cursor = db_connection.cursor()
        cursor.execute("""
            SELECT descripcion, recomendacion 
            FROM TblNivelAnemia 
            WHERE nivel_anemia = %s
        """, (int(nivel_anemia),))  # Convertir nivel_anemia a int para evitar errores
        result = cursor.fetchone()

        # Verificar que se encontró el nivel de anemia
        if result:
            descripcion, recomendacion = result
            return jsonify({
                'nivel_anemia': int(nivel_anemia),  # Convertir a tipo nativo
                'descripcion': descripcion,
                'recomendacion': recomendacion
            })
        else:
            return jsonify({'error': 'No se encontró información para el nivel de anemia.'}), 404

    except Exception as e:
        return jsonify({'error': str(e)}), 500



# API para insertar datos en MySQL
@app.route('/api/insert', methods=['POST'])
def insert_data():
    try:
        data = request.json

        # Validar campos requeridos
        required_fields = ['dni_usuario', 'nombres', 'sexo', 'region', 'talla', 'peso', 'hemoglobina', 'edad']
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"El campo {field} es obligatorio."}), 400

        conn = get_db_connection()
        cursor = conn.cursor()

        # Generar ID personalizado para TblCrecimiento
        cursor.execute("SELECT id_crecimiento FROM TblCrecimiento ORDER BY id_crecimiento DESC LIMIT 1")
        last_crecimiento_id = cursor.fetchone()
        if last_crecimiento_id and last_crecimiento_id[0]:
            # Si existe un último ID, calcular el siguiente
            next_crecimiento_id = f"CRECIM-{int(last_crecimiento_id[0].split('-')[1]) + 1:05d}"
        else:
            # Si no hay registros, comenzar desde el primer ID
            next_crecimiento_id = "CRECIM-00001"

        # Insertar en TblCrecimiento
        query_crecimiento = """
        INSERT INTO TblCrecimiento (id_crecimiento, talla, peso, hemoglobina, edad)
        VALUES (%s, %s, %s, %s, %s)
        """
        cursor.execute(query_crecimiento, (
            next_crecimiento_id,
            data['talla'],
            data['peso'],
            data['hemoglobina'],
            data['edad']
        ))

        # Generar ID personalizado para TblInfante
        cursor.execute("SELECT id_infante FROM TblInfante ORDER BY id_infante DESC LIMIT 1")
        last_infante_id = cursor.fetchone()
        if last_infante_id and last_infante_id[0]:
            # Si existe un último ID, calcular el siguiente
            next_infante_id = f"INFANTE-{int(last_infante_id[0].split('-')[1]) + 1:05d}"
        else:
            # Si no hay registros, comenzar desde el primer ID
            next_infante_id = "INFANTE-00001"

        # Insertar en TblInfante
        query_infante = """
        INSERT INTO TblInfante (id_infante, dni_usuario, nombres, sexo, region, id_crecimiento)
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query_infante, (
            next_infante_id,
            data['dni_usuario'],
            data['nombres'],
            data['sexo'],
            data['region'],
            next_crecimiento_id
        ))

        # Confirmar transacción
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"mensaje": "Datos insertados correctamente.", "id_infante": next_infante_id})
    except Exception as e:
        return jsonify({"error": str(e)}), 500



# API para recuperar datos de MySQL
@app.route('/api/infantes', methods=['GET'])
def get_infantes():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Consultar todos los infantes
        query = """
        SELECT TblInfante.*, TblCrecimiento.talla, TblCrecimiento.peso, TblCrecimiento.hemoglobina, TblCrecimiento.edad
        FROM TblInfante
        JOIN TblCrecimiento ON TblInfante.id_crecimiento = TblCrecimiento.id_crecimiento
        """
        cursor.execute(query)
        rows = cursor.fetchall()

        cursor.close()
        conn.close()

        # Agregar validación para cuando no hay resultados
        if not rows:
            return jsonify({"mensaje": "No se encontraron registros."}), 404

        return jsonify(rows)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
# API para insertar diagnóstico
@app.route('/api/diagnostico', methods=['POST'])
def insertar_diagnostico():
    try:
        data = request.json

        # Validar los campos requeridos
        required_fields = ['dni_usuario', 'id_infante', 'nivel_anemia', 'fecha_diagnostico', 'hora_diagnostico']
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"El campo {field} es obligatorio."}), 400

        # Conectar a la base de datos
        conn = get_db_connection()

        # Verificar que el infante pertenece al usuario
        cursor = conn.cursor()
        cursor.execute("""
            SELECT id_infante FROM TblInfante 
            WHERE DNI_Usuario = %s AND id_infante = %s
        """, (data['dni_usuario'], data['id_infante']))
        infante = cursor.fetchone()

        if not infante:
            cursor.close()  # Cerrar el cursor si no se encuentra el infante para el usuario
            return jsonify({"error": "No se encontró un infante con ese ID para el usuario especificado."}), 404

        # Generar un ID personalizado para el diagnóstico
        cursor.execute("SELECT id_diagnostico FROM TblDiagnostico ORDER BY id_diagnostico DESC LIMIT 1")
        last_diagnostico_id = cursor.fetchall()
        if last_diagnostico_id and last_diagnostico_id[0]:
            # Si existe un último ID, calcular el siguiente
            next_diagnostico_id = f"DIAGNOSTI-{int(last_diagnostico_id[0][0].split('-')[1]) + 1:05d}"
        else:
            # Si no hay registros, comenzar desde el primer ID
            next_diagnostico_id = "DIAGNOSTI-00001"

        # Ahora insertamos el diagnóstico
        query_diagnostico = """
            INSERT INTO TblDiagnostico (id_diagnostico, id_infante, nivel_anemia, fecha_diagnostico, hora_diagnostico, DNI_Usuario)
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query_diagnostico, (
            next_diagnostico_id,
            data['id_infante'],  # id_infante
            data['nivel_anemia'],
            data['fecha_diagnostico'],
            data['hora_diagnostico'],
            data['dni_usuario']  # DNI del usuario que realiza el diagnóstico
        ))

        # Confirmar transacción
        conn.commit()

        # Cerrar el cursor y la conexión
        cursor.close()
        conn.close()

        return jsonify({"mensaje": "Diagnóstico registrado correctamente."})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

    
# API para usuarios
@app.route('/api/verificar_usuario', methods=['POST'])
def verificar_usuario():
    try:
        data = request.json

        # Validar que el DNI esté en la solicitud
        if 'dni_usuario' not in data:
            return jsonify({"error": "El campo dni_usuario es obligatorio."}), 400

        dni_usuario = data['dni_usuario']

        # Conexión a la base de datos
        conn = get_db_connection()
        cursor = conn.cursor()

        # Verificar si el usuario ya existe
        query_verificar = "SELECT DNI FROM TblUsuario WHERE DNI = %s"
        cursor.execute(query_verificar, (dni_usuario,))
        usuario_existente = cursor.fetchone()

        if usuario_existente:
            # El usuario ya existe
            mensaje = "Usuario existente. Puede proceder a ingresar los datos del infante."
        else:
            # Crear un nuevo usuario
            query_insertar = "INSERT INTO TblUsuario (DNI) VALUES (%s)"
            cursor.execute(query_insertar, (dni_usuario,))
            conn.commit()
            mensaje = "Nuevo usuario creado exitosamente. Puede proceder a ingresar los datos del infante."

        cursor.close()
        conn.close()

        return jsonify({"mensaje": mensaje})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

#PMV2 Lógica Clustering Map
@app.route('/api/clustering-map', methods=['GET'])
def clustering_map():
    try:
        # Conectar a la base de datos
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Consulta de datos necesarios para clustering
        query = """
        SELECT TblInfante.region, TblCrecimiento.talla, TblCrecimiento.peso, 
               TblCrecimiento.hemoglobina, TblCrecimiento.edad, TblDiagnostico.nivel_anemia
        FROM TblInfante
        JOIN TblCrecimiento ON TblInfante.id_crecimiento = TblCrecimiento.id_crecimiento
        JOIN TblDiagnostico ON TblInfante.id_infante = TblDiagnostico.id_infante
        """
        cursor.execute(query)
        rows = cursor.fetchall()

        if not rows:
            return jsonify({"error": "No se encontraron datos para clustering."}), 404

        # Convertir los datos a DataFrame
        df = pd.DataFrame(rows)

        # Validar que 'region' esté disponible en los datos
        if 'region' not in df.columns:
            return jsonify({"error": "La columna 'region' no está disponible en los datos."}), 400

        # Agrupar datos por región y calcular el nivel promedio de anemia
        grouped = df.groupby('region').agg({
            'nivel_anemia': 'mean'
        }).reset_index()

        # Normalizar los niveles de riesgo
        norm = colors.Normalize(vmin=1, vmax=4)
        colormap = cm.get_cmap('RdYlGn')  # Escala de colores: rojo a verde

        # Coordenadas de las regiones
        region_coords = {
            'Junín': (-11.1582, -75.9931),
            'Yauli': (-11.7895, -76.0244),
            'Tarma': (-11.4186, -75.6902),
            'Chanchamayo': (-11.0544, -75.3371),
            'Satipo': (-11.2523, -74.6382),
            'Jauja': (-11.7761, -75.4965),
            'Concepción': (-11.9192, -75.3263),
            'Huancayo': (-12.0659, -75.2048),
            'Chupaca': (-12.0566, -75.2796),
        }

        # Crear el mapa base
        m = folium.Map(location=[-12.0659, -75.2048], zoom_start=8)

        # Añadir los puntos al mapa
        for _, row in grouped.iterrows():
            region = row['region']
            if region in region_coords:
                coord = region_coords[region]
                risk_level = row['nivel_anemia']

                # Escalar el tamaño del círculo según el riesgo
                circle_size = 5 + (risk_level * 10)

                # Obtener el color basado en el nivel de riesgo
                rgba_color = colormap(norm(risk_level))
                hex_color = colors.to_hex(rgba_color)

                # Crear el marcador en el mapa
                folium.CircleMarker(
                    location=coord,
                    radius=circle_size,
                    color=hex_color,
                    fill=True,
                    fill_opacity=0.5,
                    popup=f"<b>Región:</b> {region}<br>"
                          f"<b>Nivel de riesgo promedio:</b> {risk_level:.2f}"
                ).add_to(m)

        # Guardar el mapa como archivo HTML
        static_folder = os.path.join(os.getcwd(), 'static')
        if not os.path.exists(static_folder):
            os.makedirs(static_folder)

        output_path = os.path.join(static_folder, 'clustering_map.html')
        m.save(output_path)

        cursor.close()
        conn.close()

        # Retornar la ruta del archivo
        map_url = "/static/clustering_map.html"
        return jsonify({'map_url': map_url})

    except Exception as e:
        print(f"Error en /api/clustering-map: {str(e)}")
        return jsonify({'error': f"Error en el servidor: {str(e)}"}), 500


modelo_desnutricion = joblib.load('modelo_desnutricion.pkl')

#PMV3 Lógica Clustering Map
@app.route('/api/predict-malnutrition', methods=['POST'])
def predictMalnutrition():
    try:
        data = request.json

        # Obtener el DNI del usuario
        dni_usuario = data['dni_usuario']

        # Conectar a la base de datos y obtener los datos del infante
        cursor = db_connection.cursor()
        cursor.execute("""
            SELECT TblInfante.id_infante, TblInfante.nombres, TblInfante.sexo, TblInfante.region, 
                   TblCrecimiento.edad, TblCrecimiento.peso, TblCrecimiento.talla, TblCrecimiento.hemoglobina
            FROM TblInfante
            JOIN TblCrecimiento ON TblInfante.id_crecimiento = TblCrecimiento.id_crecimiento
            WHERE TblInfante.DNI_Usuario = %s
        """, (dni_usuario,))
        rows = cursor.fetchall()

        if not rows:
            return jsonify({'error': 'No se encontraron infantes para este usuario.'}), 404

        # Recorrer los resultados y hacer predicciones para cada infante
        predictions = []
        for row in rows:
            infante_data = {
                'id_infante': row['id_infante'],
                'nombres': row['nombres'],
                'sexo': row['sexo'],
                'region': row['region'],
                'edad': row['edad'],
                'peso': row['peso'],
                'talla': row['talla'],
                'hemoglobina': row['hemoglobina']
            }

            # Preparar los datos para el modelo
            input_data = pd.DataFrame({
                'HW1': [infante_data['edad']],
                'HW2': [infante_data['peso']],
                'HW3': [infante_data['talla']],
                'HW53': [infante_data['hemoglobina']]
            })

            # Realizar la predicción
            nivel_anemia = modelo_arbol.predict(input_data)[0]

            # Obtener la descripción y recomendación del nivel de anemia
            cursor.execute("""
                SELECT descripcion, recomendacion 
                FROM TblNivelAnemia 
                WHERE nivel_anemia = %s
            """, (int(nivel_anemia),))
            result = cursor.fetchone()

            if result:
                descripcion, recomendacion = result
                predictions.append({
                    'id_infante': infante_data['id_infante'],
                    'nombres': infante_data['nombres'],
                    'nivel_anemia': int(nivel_anemia),
                    'descripcion': descripcion,
                    'recomendacion': recomendacion
                })

        cursor.close()

        # Si no hay predicciones, retornar un error
        if not predictions:
            return jsonify({'error': 'No se pudo realizar la predicción.'}), 500

        return jsonify({'predictions': predictions})

    except Exception as e:
        return jsonify({'error': str(e)}), 500





# Iniciar el servidor Flask
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
