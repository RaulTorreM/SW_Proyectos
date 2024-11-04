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
$data = json_decode(file_get_contents("php://input"), true);

// Verificar que los datos necesarios estén presentes
if (!isset($data['DNI_Usuario'], $data['nombres'], $data['sexo'], $data['talla'], $data['peso'], $data['hemoglobina'], $data['edad'], $data['region'])) {
    echo json_encode(["success" => false, "message" => "Faltan datos en la solicitud"]);
    exit();
}

$DNI_Usuario = $data['DNI_Usuario'];
$nombres = $data['nombres'];
$sexo = $data['sexo'];
$talla = $data['talla'];
$peso = $data['peso'];
$hemoglobina = $data['hemoglobina'];
$edad = $data['edad'];
$region = $data['region'];

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

if ($result->num_rows === 0) {
    $stmt = $conn->prepare("INSERT INTO TblUsuario (DNI) VALUES (?)");
    $stmt->bind_param("s", $DNI_Usuario);
    if (!$stmt->execute()) {
        echo json_encode(["success" => false, "message" => "Error al agregar DNI en TblUsuario"]);
        $stmt->close();
        $conn->close();
        exit();
    }
}

// Insertar en TblCrecimiento
$stmt = $conn->prepare("INSERT INTO TblCrecimiento (talla, peso, hemoglobina, edad) VALUES (?, ?, ?, ?)");
$stmt->bind_param("iddd", $talla, $peso, $hemoglobina, $edad);

if ($stmt->execute()) {
    $id_crecimiento = $stmt->insert_id;

    // Insertar en TblInfante, incluyendo la región
    $stmt = $conn->prepare("INSERT INTO TblInfante (DNI_Usuario, nombres, sexo, region, id_crecimiento) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssi", $DNI_Usuario, $nombres, $sexo, $region, $id_crecimiento);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Infante agregado correctamente"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al agregar infante"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Error al insertar datos de crecimiento"]);
}

$stmt->close();
$conn->close();
?>
