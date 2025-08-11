<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">
    <title>Terms of Service</title>

    <!--
        Reminder to self: Garry's Mod's HTML is based on Awesomium, which is based on Chromium 18.
        This means that some modern features are not supported. So no fancy ES6 features like let,
        const, etc. And no CSS features like flexbox, grid, etc.
    -->

    <style>
        @font-face {
            font-family: "LightsOut";
            src: url(assets/lightout.woff)
        }

        * {
            box-sizing: border-box;
        }

        html,
        body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
        }

        body {
            background: black;
            color: white;
            padding: 1em;
            font-size: 16px;
            font-family: Verdana, Geneva, Tahoma, sans-serif;
        }

        h1,
        h2,
        h3,
        h4,
        h5,
        h6 {
            color: #A33426;
            font-family: "LightsOut";
            margin: 0;
        }

        h2 {
            font-size: 1.8em;
            font-weight: 900;
            position: relative;
            z-index: 1;
        }

        .wrapper {
            max-width: 512px;
            margin: 0 auto;
        }

        .logo {
            max-width: 256px;
        }

        img {
            position: relative;
            width: 100%;
            padding: 0;
            margin: 0;
        }

        p {
            margin: 0.5em;
            line-height: 1.5em;
        }

        ul {
            list-style-type: none;
            margin: 0.25em 0 0 0;
            padding: 0;
            position: relative;
            z-index: 1;
        }

        ul li::before {
            content: "•";
            color: #A33426;
            display: inline-block;
            margin: 0.5em;
        }

        .hidden {
            display: none;
        }

        .inline-block {
            display: inline-block;
        }

        .my {
            margin-top: 2em;
            margin-bottom: 2em;
        }

        .mt-s {
            margin-top: 1em;
        }

        a,
        .highlight {
            color: #A33426;
        }

        button {
            background: #A33426;
            color: white;
            border: none;
            font-size: 1em;
            padding: .5em 1em;
            margin: 0.5em 0;
            cursor: pointer;
            font-family: Verdana, Geneva, Tahoma, sans-serif;
            width: 100%;
        }

        button.huge {
            font-size: 2em;
            padding: .8em 1em;
        }

        button.gray {
            background: #333;
        }

        input {
            width: 100%;
            padding: .5em;
            margin: 0.5em 0;
            font-size: 1em;
        }

        .font-bold {
            font-weight: bold;
        }
    </style>
</head>

<body>
    @php
        $rules = require app_path('Data/Rules.php');
    @endphp

    @foreach ($rules as $rule)
    <li class="mt-s">
        <h3 class="font-bold inline-block">{{ $rule['title'] }}</h3>
        <p>{{ $rule['description'] }}</p>
    </li>
    @endforeach
</body>

</html>
