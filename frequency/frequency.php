<?php

include("by-taxon.php");

$files =  array_diff(scandir("data"), array('.', '..'));

$file = fopen('recordings.txt', "r");
fgetcsv($file);

$output = array();

while ($row = fgetcsv($file)) {
  if (!file_exists("data/$row[0].csv")) {
    continue;
  }
  $d = fopen("data/$row[0].csv", "r");
  $data = array();
  while ($e = fgetcsv($d)) {
    $data[] = $e;
  }
  $data_clean = array(
    "min" => $data[1][1],
    "max" => $data[2][1],
    "centre" => $data[4][1],
    "peak" => $data[3][1],
    "bandwidth" => $data[2][1] - $data[1][1]
  );
  if ($data_clean["bandwidth"] < 0) {
    $data_clean["bandwidth"] = $data_clean["bandwidth"] * -1;
  }
  $output[] = array(get_parent_by_rank($row[1], "Family") => $data_clean);
}

$analyse = array();
foreach ($output as $stat) {
  foreach ($stat as $taxon => $data) {
    $analyse[$taxon]["bandwidth"][] = $data["bandwidth"];
    $analyse[$taxon]["centre"][] = $data["centre"];
  }
}

function StdDev($Array) {
  if( count($Array) < 2 ) {
    return;
  }
 
  $avg = array_sum($Array) / count($Array);;
 
  $sum = 0;
  foreach($Array as $value) {
    $sum += pow($value - $avg, 2);
  }
 
  return sqrt((1 / (count($Array) - 1)) * $sum);
}

$complete = array();
foreach ($analyse as $taxon => $data) {
  foreach ($data as $type => $values) {
    $complete[$taxon][$type]["mean"] = array_sum($values) / count($values);
    $complete[$taxon][$type]["sd"] = StdDev($values);
  }
}

print_r($complete);
