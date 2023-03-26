{ lib
, buildPythonPackage
, fetchFromGitHub
, mock
, nose
, nose2
, pytestCheckHook
, pythonOlder
, setuptools
}:

buildPythonPackage rec {
  pname = "parameterized";
  version = "0.8.1";
  format = "pyproject";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "wolever";
    repo = "parameterized";
    rev = "e383e1e18d891fd74feef70fd3a70e1ec87fc7e8";
    hash = "sha256-/S5kt6h+8Q1YneU3WhC93UkM5z4PJv2Ak+LHoT6uPzc=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  checkInputs = [
    mock
  ] ++ lib.optionals (pythonOlder "3.10") [
    nose
  ];

  checkPhase = ''
    runHook preCheck

    python -m unittest parameterized/test.py

    runHook postCheck
  '';

  pythonImportsCheck = [
    "parameterized"
  ];

  meta = with lib; {
    description = "Parameterized testing with any Python test framework";
    homepage = "https://github.com/wolever/parameterized";
    changelog = "https://github.com/wolever/parameterized/blob/v${version}/CHANGELOG.txt";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
  };
}
