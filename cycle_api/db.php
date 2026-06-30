<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

$connect = mysqli_connect('localhost', 'root', '', 'cycle_app');

if (!$connect) {
    echo json_encode(['status' => 'gagal', 'message' => 'Koneksi database gagal: ' . mysqli_connect_error()]);
    exit;
}

$method = $_SERVER['REQUEST_METHOD'];

if ($method == 'GET') {
    $user_id = $_GET['user_id'] ?? 0;
    $endpoint = $_GET['endpoint'] ?? '';
    
    if ($endpoint == 'menstruasi') {
        $sql = "SELECT * FROM menstruasi WHERE user_id = '$user_id' ORDER BY tanggal_mulai DESC";
        $result = mysqli_query($connect, $sql);
        $data = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $data[] = $row;
        }
        echo json_encode($data);
    } 
    elseif ($endpoint == 'mood') {
        $sql = "SELECT * FROM mood WHERE user_id = '$user_id' ORDER BY tanggal DESC LIMIT 30";
        $result = mysqli_query($connect, $sql);
        $data = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $data[] = $row;
        }
        echo json_encode($data);
    }
    //  TIPS
    elseif ($endpoint == 'tips') {
        $mood = $_GET['mood'] ?? '';
        $sql = "SELECT * FROM tips WHERE mood = '$mood'";
        $result = mysqli_query($connect, $sql);
        $data = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $data[] = $row;
        }
        echo json_encode($data);
    }
    elseif ($endpoint == 'user') {
        $sql = "SELECT id, username FROM users WHERE id = '$user_id'";
        $result = mysqli_query($connect, $sql);
        $data = mysqli_fetch_assoc($result);
        if ($data) {
            echo json_encode($data);
        } else {
            echo json_encode(['status' => 'gagal', 'message' => 'User tidak ditemukan']);
        }
    }
}
elseif ($method == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    if ($input == null) {
        $input = $_POST;
    }
    $endpoint = $input['endpoint'] ?? '';
    
    if ($endpoint == 'register') {
        $username = $input['username'];
        $password = $input['password'];
        
        $check = mysqli_query($connect, "SELECT id FROM users WHERE username = '$username'");
        if (mysqli_num_rows($check) > 0) {
            echo json_encode(['status' => 'gagal', 'message' => 'Username sudah digunakan!']);
            exit;
        }
        
        $sql = "INSERT INTO users (username, password) VALUES ('$username', '$password')";
        $result = mysqli_query($connect, $sql);
        if ($result) {
            echo json_encode(['status' => 'sukses', 'message' => 'Registrasi berhasil', 'id' => mysqli_insert_id($connect)]);
        } else {
            echo json_encode(['status' => 'gagal', 'message' => mysqli_error($connect)]);
        }
        exit;
    }
    elseif ($endpoint == 'login') {
        $username = $input['username'];
        $password = $input['password'];
        $sql = "SELECT id, username FROM users WHERE username = '$username' AND password = '$password'";
        $result = mysqli_query($connect, $sql);
        if ($row = mysqli_fetch_assoc($result)) {
            echo json_encode(['status' => 'sukses', 'data' => $row]);
        } else {
            echo json_encode(['status' => 'gagal', 'message' => 'Username atau password salah']);
        }
        exit;
    }
    elseif ($endpoint == 'tambah_menstruasi') {
        $user_id = $input['user_id'] ?? 0;
        $tanggal_mulai = $input['tanggal_mulai'] ?? '';
        $tanggal_selesai = $input['tanggal_selesai'] ?? null;
        $siklus_ke = $input['siklus_ke'] ?? 1;
        $catatan = $input['catatan'] ?? '';

        if (empty($user_id) || empty($tanggal_mulai)) {
            echo json_encode(['status' => 'gagal', 'message' => 'Data tidak lengkap']);
            exit;
        }

        $sql = "INSERT INTO menstruasi (user_id, tanggal_mulai, tanggal_selesai, siklus_ke, catatan) 
                VALUES ('$user_id', '$tanggal_mulai', '$tanggal_selesai', '$siklus_ke', '$catatan')";
        
        $result = mysqli_query($connect, $sql);
        
        if ($result) {
            echo json_encode(['status' => 'sukses', 'message' => 'Data berhasil disimpan']);
        } else {
            echo json_encode(['status' => 'gagal', 'message' => mysqli_error($connect)]);
        }
        exit;
    }
    elseif ($endpoint == 'update_menstruasi') {
        $id = $input['id'];
        $user_id = $input['user_id'];
        $tanggal_mulai = $input['tanggal_mulai'];
        $tanggal_selesai = $input['tanggal_selesai'] ?? null;
        $siklus_ke = $input['siklus_ke'] ?? 1;
        $catatan = $input['catatan'] ?? '';

        $sql = "UPDATE menstruasi SET 
                tanggal_mulai = '$tanggal_mulai',
                tanggal_selesai = '$tanggal_selesai',
                siklus_ke = '$siklus_ke',
                catatan = '$catatan'
                WHERE id = '$id' AND user_id = '$user_id'";
        
        $result = mysqli_query($connect, $sql);
        if ($result) {
            echo json_encode(['status' => 'sukses', 'message' => 'Data berhasil diupdate']);
        } else {
            echo json_encode(['status' => 'gagal', 'message' => mysqli_error($connect)]);
        }
        exit;
    }
    elseif ($endpoint == 'tambah_mood') {
        $user_id = $input['user_id'];
        $tanggal = $input['tanggal'];
        $mood = $input['mood'];
        $catatan = $input['catatan'] ?? '';
        $sql = "INSERT INTO mood (user_id, tanggal, mood, catatan) VALUES ('$user_id', '$tanggal', '$mood', '$catatan')";
        $result = mysqli_query($connect, $sql);
        if ($result) {
            echo json_encode(['status' => 'sukses', 'message' => 'Mood berhasil dicatat']);
        } else {
            echo json_encode(['status' => 'gagal', 'message' => mysqli_error($connect)]);
        }
        exit;
    }
}
elseif ($method == 'DELETE') {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = $input['id'];
    $endpoint = $input['endpoint'] ?? '';
    
    if ($endpoint == 'menstruasi') {
        $sql = "DELETE FROM menstruasi WHERE id = '$id'";
    } elseif ($endpoint == 'mood') {
        $sql = "DELETE FROM mood WHERE id = '$id'";
    }
    
    $result = mysqli_query($connect, $sql);
    if ($result) {
        echo json_encode(['status' => 'sukses', 'message' => 'Data berhasil dihapus']);
    } else {
        echo json_encode(['status' => 'gagal', 'message' => mysqli_error($connect)]);
    }
    exit;
}
?>