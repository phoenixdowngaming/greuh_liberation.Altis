// force disabling of fatigure by default
player enableFatigue false;
player addMPEventhandler ["MPRespawn", {player enableFatigue false}];

// turn off sentences (commander orders)
enableSentences false;

// add in custom mods
_null = [] execVM "PDG\earplug\earplugInit.sqf";
_null =	[] execVM 'PDG\QS_TurretSafetySystem.sqf';							//Turret Safety System
