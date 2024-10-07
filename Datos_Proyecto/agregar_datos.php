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

// Verificar que los datos necesarios estén presentes
if (!isset($data['DNI_Usuario'], $data['nombres'], $data['sexo'], $data['talla'], $data['peso'], $data['hemoglobina'], $data['edad'])) {
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

// Validar longitud del DNI
if (strlen($DNI_Usuario) > 8) {
    echo json_encode(["success" => false, "message" => "El DNI debe tener un máximo de 8 caracteres"]);
    exit();
}

// Verifica si los datos son válidos
if (is_numeric($edad) && is_numeric($peso) && is_numeric($talla) && is_numeric($hemoglobina)) {
    // Verificar si el DNI ya existe en TblUsuario
    $stmt = $conn->prepare("SELECT DNI FROM TblUsuario WHERE DNI = ?");
    $stmt->bind_param("s", $DNI_Usuario);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        // Si no existe, insertar el DNI en TblUsuario
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
        $id_crecimiento = $stmt->insert_id; // Obtener el ID del crecimiento insertado

        // Insertar en TblInfante
        $stmt = $conn->prepare("INSERT INTO TblInfante (DNI_Usuario, nombres, sexo, id_crecimiento) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("sssi", $DNI_Usuario, $nombres, $sexo, $id_crecimiento);

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Infante agregado correctamente"]);
        } else {
            echo json_encode(["success" => false, "message" => "Error al agregar infante"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Error al insertar datos de crecimiento"]);
    }

    $stmt->close();
} else {
    echo json_encode(["success" => false, "message" => "Datos no válidos"]);
}

$conn->close();
?>