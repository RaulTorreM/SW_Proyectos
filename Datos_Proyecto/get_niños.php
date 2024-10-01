<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$conn = new mysqli("localhost", "root", "", "db_proyectos");

if ($conn->connect_error) {
    die(json_encode(["error" => "Conexión fallida: " . $conn->connect_error]));
}

$result = $conn->query("SELECT * FROM niños_salud");

if ($result->num_rows > 0) {
    $data = array();

    while ($row = $result->fetch_assoc()) {
        // Asegúrate de que estás enviando los tipos correctos
        $data[] = array(
            'id' => (int)$row['id'],
            'edad' => (int)$row['edad'],
            'peso' => (float)$row['peso'],
            'talla' => (float)$row['talla'],
            'hemoglobina' => (float)$row['hemoglobina'],
        );
    }

    echo json_encode($data);
} else {
    echo json_encode([]);
}

$conn->close();
?>
