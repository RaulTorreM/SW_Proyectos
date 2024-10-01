<?php
header('Access-Control-Allow-Origin: *'); // Permitir solicitudes de cualquier origen
header('Access-Control-Allow-Headers: Content-Type'); // Permitir el encabezado Content-Type
header('Content-Type: application/json');

$conn = new mysqli("localhost", "root", "", "db_proyectos");

if ($conn->connect_error) {
    die(json_encode(["error" => "Conexión fallida: " . $conn->connect_error]));
}

// Obtener los datos del cuerpo de la solicitud
$data = json_decode(file_get_contents("php://input"), true); // Asegúrate de que recibes los datos correctamente

$edad = $data['edad'];
$peso = $data['peso'];
$talla = $data['talla'];
$hemoglobina = $data['hemoglobina'];

// Verifica si los datos son válidos antes de insertar
if (is_numeric($edad) && is_numeric($peso) && is_numeric($talla) && is_numeric($hemoglobina)) {
    // Preparar la consulta para evitar inyecciones SQL
    $stmt = $conn->prepare("INSERT INTO niños_salud (edad, peso, talla, hemoglobina) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("iddd", $edad, $peso, $talla, $hemoglobina); // 'i' for integer, 'd' for double

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Datos insertados correctamente"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al insertar datos"]);
    }

    $stmt->close();
} else {
    echo json_encode(["success" => false, "message" => "Datos no válidos"]);
}

$conn->close();
?>
