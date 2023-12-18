<?php

use Slim\App;
use Slim\Http\Request;
use Slim\Http\Response;
use Slim\Http\UploadedFile;
use PhpOffice\PhpSpreadsheet\Spreadsheet;

return function (App $app) {
    $container = $app->getContainer();

    //------------------------------------UAS progmob 2023 tentang MapProject------------------------------

    $app->get("/mapproject/{nim}/", function (Request $request, Response $response, $args) {
        $nim = $args["nim"];
        $sql = "SELECT * FROM `$nim`";
        $stmt = $this->db->prepare($sql);
        $stmt->execute();
        $result = $stmt->fetchAll();
        return $response->withJson(["status" => "success", "data" => $result], 200);
    });
    
    $app->get("/mapproject/{nim}/{kategori}", function (Request $request, Response $response, $args) {
        $nim = $args["nim"];
        $kategori = $args["kategori"];
        $sql = "SELECT * FROM `$nim` WHERE kategori=:kategori";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([":kategori" => $kategori]);
        $result = $stmt->fetch();
        return $response->withJson(["status" => "success", "data" => $result], 200);
    });
    
    $app->post("/mapproject/{nim}/", function (Request $request, Response $response, $args) {
        $nim = $args["nim"];
        $mapProject = $request->getParsedBody();
        
        $nim = preg_replace("/[^a-zA-Z0-9_]+/", "", $nim);
    
        $sql = "INSERT INTO `$nim` (nama, kategori, keterangan, lat, lng) VALUES (:nama, :kategori, :keterangan, :lat, :lng)";
        $stmt = $this->db->prepare($sql);
    
        $data = [
            ":nama" => $mapProject["nama"],
            ":kategori" => $mapProject["kategori"],
            ":keterangan" => $mapProject["keterangan"],
            ":lat" => $mapProject["lat"],
            ":lng" => $mapProject["lng"],
        ];
    
        if ($stmt->execute($data)) {
            return $response->withJson(["status" => "success", "data" => "1"], 200);
        }
    
        return $response->withJson(["status" => "failed", "data" => "0"], 200);
    });
    
};