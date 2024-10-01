from flask import Flask, request, jsonify
from flask_cors import CORS  # Importar CORS
import joblib
import numpy as np

app = Flask(__name__)
CORS(app)  # Habilitar CORS para toda la aplicación

# Cargar el modelo de Machine Learning
modelo = joblib.load('C:/xampp/htdocs/Datos_proyecto/modelo/modelo.pkl')  # Cambia la ruta si es necesario

# Ruta para hacer la predicción
@app.route('/predict', methods=['POST'])
def predict():
    # Obtener los datos enviados en formato JSON
    datos = request.get_json()

    # Extraer las características (edad, peso, talla, hemoglobina)
    edad = datos['edad']
    peso = datos['peso']
    talla = datos['talla']
    hemoglobina = datos['hemoglobina']

    # Crear el array con los datos
    input_data = np.array([[edad, peso, talla, hemoglobina]])

    # Hacer la predicción usando el modelo cargado
    prediccion = modelo.predict(input_data)

    # Devolver la predicción en formato JSON
    return jsonify({'prediccion': int(prediccion[0])})

if __name__ == '__main__':
    app.run(port=5000, debug=True)  # Ejecutar en el puerto 5000
