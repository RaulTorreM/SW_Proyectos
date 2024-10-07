<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

// Conexión a la base de datos
$conn = new mysqli("localhost", "root", "", "db_proyectos");

// Verificar la conexión
if ($conn->connect_error) {
    die(json_encode(["error" => "Conexión fallida: " . $conn->connect_error]));
}

// Consulta a la base de datos para obtener datos de TblCrecimiento
$result = $conn->query("SELECT * FROM TblCrecimiento"); // Asegúrate de que el nombre de la tabla sea correcto

if ($result) {
    if ($result->num_rows > 0) {
        $data = array();

        while ($row = $result->fetch_assoc()) {
            // Asegúrate de que estás enviando los tipos correctos
            $data[] = array(
                'id_crecimiento' => (int)$row['id_crecimiento'],
                'talla' => (float)$row['talla'],
                'peso' => (float)$row['peso'],
                'hemoglobina' => (float)$row['hemoglobina'],
                'edad' => (int)$row['edad'],
            );
        }

        echo json_encode($data);
    } else {
        echo json_encode([]); // No hay resultados
    }
} else {
    // Manejo de errores en la consulta
    echo json_encode(["error" => "Error en la consulta: " . $conn->error]);
}

// Cerrar la conexión
$conn->close();
?>