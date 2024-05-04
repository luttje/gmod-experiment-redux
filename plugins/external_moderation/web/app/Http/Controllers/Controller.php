<?php

namespace App\Http\Controllers;

abstract class Controller
{
    // TODO: There must be a better way to do this.
    protected function fixRequest($request)
    {
        // If the request is x-www-form-urlencoded, then expand the 'json' value from the request into the request data.
        if ($request->header('Content-Type') === 'application/x-www-form-urlencoded') {
            $json = json_decode($request->input('json'), true);

            foreach ($json as $key => $value) {
                $request->request->set($key, $value);
            }

            $request->request->remove('json');
        // If it's json, leave it as is.
        } elseif ($request->header('Content-Type') !== 'application/json') {
            $headers = collect($request->header())->transform(function ($item) {
                return $item[0];
            });
            dd(json_encode($headers, JSON_PRETTY_PRINT) . '    /    ' . json_encode($request->all(), JSON_PRETTY_PRINT));
        }
    }
}
