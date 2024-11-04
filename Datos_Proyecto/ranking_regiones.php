<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

// Conexión a la base de datos
$conn = new mysqli("localhost", "root", "", "db_proyectos");

// Verificar la conexión
if ($conn->connect_error) {
    die(json_encode(["error" => "Conexión fallida: " . $conn->connect_error]));
}

// Consultar la cantidad de casos de anemia por región
$sql = "
    SELECT region, COUNT(*) AS casos_anemia
    FROM TblInfante AS i
    INNER JOIN TblDiagnostico AS d ON i.id_infante = d.id_infante
    WHERE d.nivel_anemia IN (1, 2, 3) -- Considera solo los niveles con anemia
    GROUP BY region
    ORDER BY casos_anemia DESC
";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $ranking = [];
    while ($row = $result->fetch_assoc()) {
        $ranking[] = $row;
    }
    echo json_encode($ranking);
} else {
    echo json_encode([]);
}

$conn->close();
?>
