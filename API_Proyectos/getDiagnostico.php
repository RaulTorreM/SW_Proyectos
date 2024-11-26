<?php
include 'conexion.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $id_infante = $_GET['id_infante'];  // Suponemos que el ID es pasado por la URL

    $sql = "SELECT * FROM TblDiagnostico WHERE id_infante = '$id_infante'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $data = $result->fetch_assoc();
        echo json_encode($data);
    } else {
        echo json_encode(['mensaje' => 'No se encontró diagnóstico para ese infante.']);
    }
}
?>
