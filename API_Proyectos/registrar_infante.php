<?php
include 'conexion.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Obtener los datos del cuerpo de la solicitud
    $data = json_decode(file_get_contents('php://input'), true);

    $dni_usuario = $data['dni_usuario'];
    $nombres = $data['nombres'];
    $sexo = $data['sexo'];
    $region = $data['region'];
    $edad = $data['edad'];
    $peso = $data['peso'];
    $talla = $data['talla'];
    $hemoglobina = $data['hemoglobina'];

    $sql = "INSERT INTO TblInfante (DNI_Usuario, nombres, sexo, region, id_crecimiento)
            VALUES ('$dni_usuario', '$nombres', '$sexo', '$region', 
                    (SELECT id_crecimiento FROM TblCrecimiento WHERE edad = $edad AND peso = $peso AND talla = $talla AND hemoglobina = $hemoglobina LIMIT 1))";
    
    if ($conn->query($sql) === TRUE) {
        echo json_encode(['mensaje' => 'Infante registrado exitosamente.']);
    } else {
        echo json_encode(['mensaje' => 'Error al registrar el infante: ' . $conn->error]);
    }
}
?>
