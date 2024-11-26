<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "db_proyecto_anemia";  // Cambia esto con el nombre de tu base de datos

// Crear conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
?>
