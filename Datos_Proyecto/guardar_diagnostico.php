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
if (!isset($data['DNI_Usuario'], $data['nombres'], $data['sexo'], $data['talla'], $data['peso'], $data['hemoglobina'], $data['edad'], $data['nivel_anemia'], $data['fecha_diagnostico'])) {
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
$nivel_anemia = $data['nivel_anemia'];
$fecha_diagnostico = $data['fecha_diagnostico'];

// Verificar si el infante existe usando los datos proporcionados
$stmt = $conn->prepare("SELECT id_infante FROM TblInfante WHERE DNI_Usuario = ? AND nombres = ? AND sexo = ?");
$stmt->bind_param("ssi", $DNI_Usuario, $nombres, $sexo);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $id_infante = $row['id_infante'];

    // Verificar si el nivel de anemia existe
    $stmt = $conn->prepare("SELECT nivel_anemia FROM TblNivelAnemia WHERE nivel_anemia = ?");
    $stmt->bind_param("i", $nivel_anemia);
    $stmt->execute();
    $result_nivel = $stmt->get_result();

    if ($result_nivel->num_rows > 0) {
        // Insertar en TblDiagnostico
        $stmt = $conn->prepare("INSERT INTO TblDiagnostico (id_infante, nivel_anemia, fecha_diagnostico) VALUES (?, ?, ?)");
        $stmt->bind_param("iis", $id_infante, $nivel_anemia, $fecha_diagnostico);

        if ($stmt->execute()) {
            echo json_encode([
                "success" => true,
                "message" => "Diagnóstico guardado correctamente",
                "id_infante" => $id_infante,
                "nivel_anemia" => $nivel_anemia,
                "fecha_diagnostico" => $fecha_diagnostico
            ]);
        } else {
            echo json_encode(["success" => false, "message" => "Error al guardar el diagnóstico"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "El nivel de anemia no existe"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Infante no encontrado"]);
}

$stmt->close();
$conn->close();
?>