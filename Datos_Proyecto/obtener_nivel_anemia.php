<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

// Conexión a la base de datos
$conn = new mysqli("localhost", "root", "", "db_proyectos");

// Verificar la conexión
if ($conn->connect_error) {
    die(json_encode(["error" => "Conexión fallida: " . $conn->connect_error]));
}

// Obtener el nivel de anemia de la solicitud
$nivel_anemia = $_GET['nivel_anemia'];

// Consultar la base de datos
$stmt = $conn->prepare("SELECT descripcion, recomendacion FROM TblNivelAnemia WHERE nivel_anemia = ?");
$stmt->bind_param("i", $nivel_anemia);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode([
        "success" => true,
        "descripcion" => $row['descripcion'],
        "recomendacion" => $row['recomendacion']
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Nivel de anemia no encontrado"]);
}

$stmt->close();
$conn->close();
?>