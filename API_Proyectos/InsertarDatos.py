import requests
import random
import string
from datetime import datetime

# Configurar las URLs de las APIs
INSERT_URL = "http://192.168.0.15:5000/api/insert"
PREDICT_URL = "http://192.168.0.15:5000/api/predict"
DIAGNOSTICO_URL = "http://192.168.0.15:5000/api/diagnostico"
VERIFICAR_USUARIO_URL = "http://192.168.0.15:5000/api/verificar_usuario"

# Regiones disponibles
REGIONES = [
    "Junín", "Yauli", "Tarma", "Chanchamayo", "Satipo", 
    "Jauja", "Concepción", "Huancayo", "Chupaca"
]

# Función para generar un DNI aleatorio
def generar_dni():
    # return ''.join(random.choices(string.digits, k=8))  # Genera un DNI aleatorio de 8 dígitos
    return '12312312'

# Función para generar datos aleatorios
def generar_datos():
    return {
        "dni_usuario": generar_dni(),
        "nombres": f"Nombre-{random.randint(1, 1000)}",
        "sexo": random.choice(["M", "F"]),
        "region": random.choice(REGIONES),
        "talla": round(random.uniform(40.0, 150.0), 1),  # Talla en cm
        "peso": round(random.uniform(1.5, 50.0), 1),    # Peso en kg
        "hemoglobina": round(random.uniform(4.5, 17.5), 1),  # Hemoglobina en g/dL
        "edad": random.randint(0, 59)               # Edad en meses
    }

# Verificar o crear el usuario
def verificar_usuario(dni_usuario):
    data_verificar = {
        "dni_usuario": dni_usuario
    }

    # Hacer la solicitud a la API de verificación de usuario
    response = requests.post(VERIFICAR_USUARIO_URL, json=data_verificar)
    return response

# Insertar el infante y recuperar su id_infante
def insertar_infante(dni_usuario, data):
    data['dni_usuario'] = dni_usuario  # Asignar el DNI del usuario insertado
    response = requests.post(INSERT_URL, json=data)
    
    if response.status_code == 200:
        # Suponiendo que la API devuelve el id_infante en la respuesta
        infante_data = response.json()
        id_infante = infante_data.get('id_infante')
        if id_infante:
            return id_infante
        else:
            print(f"Error: No se devolvió id_infante. Respuesta: {response.json()}")
            return None
    else:
        print(f"Error al insertar infante. Respuesta: {response.json()}")
        return None

# Función para insertar diagnóstico
def insertar_diagnostico(dni_usuario, id_infante, nivel_anemia):
    data_diagnostico = {
        "dni_usuario": dni_usuario,
        "id_infante": id_infante,
        "nivel_anemia": nivel_anemia,
        "fecha_diagnostico": datetime.now().strftime("%Y-%m-%d"),
        "hora_diagnostico": datetime.now().strftime("%H:%M:%S")
    }

    # Hacer la solicitud a la API de diagnóstico
    response = requests.post(DIAGNOSTICO_URL, json=data_diagnostico)
    return response

# Generar e insertar datos
for i in range(100):
    try:
        # Generar un DNI aleatorio
        dni_usuario = generar_dni()
        
        # Verificar si el usuario existe o crear uno nuevo
        response_usuario = verificar_usuario(dni_usuario)
        if response_usuario.status_code == 200:
            print(f"[{i+1}] Usuario {dni_usuario} verificado o creado correctamente.")
        else:
            print(f"[{i+1}] Error al verificar o crear el usuario {dni_usuario}: {response_usuario.json()}")
            continue  # Si hay un error, continuar con el siguiente

        # Generar un registro aleatorio de infante con el DNI ya verificado o creado
        data = generar_datos()
        
        # Insertar el registro en la base de datos
        id_infante = insertar_infante(dni_usuario, data)
        if id_infante:
            print(f"[{i+1}] Infante insertado correctamente con ID: {id_infante}")
        else:
            print(f"[{i+1}] Error al insertar infante.")
            continue
        
        # Realizar la predicción con los mismos datos
        predict_response = requests.post(PREDICT_URL, json=data)
        if predict_response.status_code == 200:
            prediccion = predict_response.json()
            if 'nivel_anemia' in prediccion and 'descripcion' in prediccion:
                nivel_anemia = prediccion['nivel_anemia']
                print(f"Predicción: Nivel de anemia - {nivel_anemia} ({prediccion['descripcion']})")
                # Insertar diagnóstico
                response_diagnostico = insertar_diagnostico(dni_usuario, id_infante, nivel_anemia)
                if response_diagnostico.status_code == 200:
                    print("Diagnóstico de anemia registrado correctamente.")
                else:
                    print(f"Error al registrar diagnóstico: {response_diagnostico.json()}")
            else:
                print(f"Error en la predicción: {prediccion}")
        else:
            print(f"Error al predecir: {predict_response.json()}")

    except Exception as e:
        print(f"Error en el ciclo de inserción: {e}")
