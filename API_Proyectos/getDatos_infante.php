<?php
include 'conexion.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $dni_usuario = $_GET['dni_usuario'];  // Suponemos que el DNI es pasado por la URL

    $sql = "SELECT * FROM TblInfante WHERE DNI_Usuario = '$dni_usuario'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $data = [];
        while($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        echo json_encode($data);
    } else {
        echo json_encode(['mensaje' => 'No se encontraron infantes con ese DNI.']);
    }
}
?>
