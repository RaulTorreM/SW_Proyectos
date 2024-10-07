<?php
header('Access-Control-Allow-Origin: *'); // Permitir solicitudes de cualquier origen
header('Access-Control-Allow-Headers: Content-Type'); // Permitir el encabezado Content-Type
header('Content-Type: application/json');

// Conexión a la base de datos
$conn = new mysqli("localhost", "root", "", "db_proyectos");

// Verificar la conexión
if ($conn->connect_error) {
    die(json_encode(["error" => "Conexión fallida: " . $conn->connect_error]));
}

// Obtener los datos del cuerpo de la solicitud
$data = json_decode(file_get_contents("php://input"), true); // Asegúrate de que recibes los datos correctamente

// Verificar que el DNI esté presente
if (!isset($data['DNI_Usuario'])) {
    echo json_encode(["success" => false, "message" => "Falta el DNI del usuario"]);
    exit();
}

$DNI_Usuario = $data['DNI_Usuario'];

// Validar longitud del DNI
if (strlen($DNI_Usuario) > 8) {
    echo json_encode(["success" => false, "message" => "El DNI debe tener un máximo de 8 caracteres"]);
    exit();
}

// Verificar si el DNI ya existe en TblUsuario
$stmt = $conn->prepare("SELECT DNI FROM TblUsuario WHERE DNI = ?");
$stmt->bind_param("s", $DNI_Usuario);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    // Si el DNI existe
    echo json_encode(["success" => true, "message" => "El DNI ya está registrado"]);
} else {
    // Si el DNI no existe, insertar en TblUsuario
    $stmt = $conn->prepare("INSERT INTO TblUsuario (DNI) VALUES (?)");
    $stmt->bind_param("s", $DNI_Usuario);
    
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "DNI creado correctamente"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al crear el DNI en TblUsuario"]);
    }
}

$stmt->close();
$conn->close();
?>