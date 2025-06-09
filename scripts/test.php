<?php
$fail = getenv('SIMULATE_FAILURE');

//simulate failure
if ($fail === 'true') {
    http_response_code(1);
    $data = [
        'status' => 'error',
        'timestamp' => date('Y-m-d H:i:s'),
        'message' => 'Simulated failure.'
    ];
    echo json_encode($data, JSON_PRETTY_PRINT);
    exit(1);
}

//or run as success
$data = [
    'status' => 'success',
    'timestamp' => date('Y-m-d H:i:s'),
    'message' => 'Test ran successfully.'
];
echo json_encode($data, JSON_PRETTY_PRINT);
