<?php
$servername = "localhost";
$username = "your_mysql_user";
$password = "your_mysql_pass";
$dbName = "your_mysql_DB";

// Create connection
$conn = mysqli_connect($servername, $username, $password, $dbName);

/*
// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully";
*/
?>

<!DOCTYPE html>
<html>
<head>
        <title>UP Hosts</title>
</head>
<body>

<?php
        $sql = "SELECT * FROM `scan` WHERE `UP` = 1 ORDER BY `scan`.`IP` ASC";
        $result = mysqli_query($conn, $sql);
        echo "<br>";
        echo "<table border='1'>";
        while ($row = mysqli_fetch_assoc($result)) {
                echo "<tr>";
                foreach ($row as $field => $value) {
                        echo "<td>" . $value . "</td>";
                }
                echo "</tr>";
        }
        echo "</table>";
?>
</body>
</html>
