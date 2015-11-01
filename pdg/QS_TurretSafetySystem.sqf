/*
File: QS_turretSafety.sqf
Author:

	Quiksilver
	
Last modified:
	
	31/08/2015 ArmA 3 1.50 by Quiksilver
	
Description:

	Pilot control over mounted aircraft weapon turrets
	
Instructions:

	Place the below line in 'initPlayerLocal.sqf' in your main mission directory:
	
		[] execVM 'QS_TurretSafetySystem.sqf';

Conditions of use:

	Please leave this section intact, do not remove/modify author section.
	You may modify the 'Last modified' section.
	All the copyright stuff, etc.
	
Note:

	This script uses remoteExec command, executing the commands 'addWeaponTurret' and 'removeWeaponTurret', executed on all connected clients to ensure synchronization 
	
	Those commands must be whitelisted in CfgRemoteExec {} in description.ext, if that is being used.
	
	eg:
	
	CfgRemoteExec {
		Functions {};
		Commands {
			addWeaponTurret {};
			removeWeaponTurret {};
		};
	};
	
____________________________________________________________________________*/

if (isDedicated) exitWith {};

private [
	'_pilotTypes','_pilotsOnly','_iAmPilot','_exit'
];

//========== CONFIG

_pilotTypes = [
	'B_Pilot_F','B_Helipilot_F','B_helicrew_F',
	'O_Pilot_F','O_helipilot_F','O_helicrew_F',
	'I_pilot_F','I_helipilot_F','I_helicrew_F',
	'C_man_pilot_F'
];

QS_TSS_heliTypes = [
	'B_Heli_Transport_01_camo_F','B_Heli_Transport_01_F','B_Heli_Transport_03_F'
];								// Supported Helicopters, add your modded ones here!

_pilotsOnly = FALSE;			// Set TRUE to restrict turret safety system to pilots/helicrew only.

//========== FILTER

_exit = FALSE;
if (_pilotsOnly) then {
	if (!((typeOf (vehicle player)) in _pilotTypes)) then {
		_exit = TRUE;
	};
};
if (_exit) exitWith {};

//========== CODE

QS_fnc_turretActionCancel = compileFinal "
	_v = vehicle player;
	QS_TSS_turretControl = FALSE;
	QS_TSS_inturretloop = FALSE;
	[_v,1,0] call QS_fnc_turretReset;
	[_v,2,0] call QS_fnc_turretReset;
";

QS_fnc_turretActions = compileFinal "
	private ['_array','_v','_turret','_lock'];
	_array = _this select 3;
	_v = _array select 0;
	_turret = _array select 1;
	_lock = _array select 2;
	{
		player removeAction _x;
	} count QS_TSS_turretActions;
	player removeAction QS_TSS_turretAction;
	if (_lock isEqualTo 0) exitWith {
		if (_turret isEqualTo 1) then {
			[_v,['LMG_Minigun_Transport',[1]]] remoteExec ['addWeaponTurret',0,FALSE];
			_v setVariable ['QS_TSS_turretL_locked',FALSE,TRUE];
		};
		if (_turret isEqualTo 2) then {
			[_v,['LMG_Minigun_Transport2',[2]]] remoteExec ['addWeaponTurret',0,FALSE];
			_v setVariable ['QS_TSS_turretR_locked',FALSE,TRUE];
		};	
		QS_TSS_turretControl = FALSE;
		QS_TSS_inturretloop = FALSE;
	};
	if (_lock isEqualTo 1) exitWith {
		if (_turret isEqualTo 1) then {
			[_v,['LMG_Minigun_Transport',[1]]] remoteExec ['removeWeaponTurret',0,FALSE];
			_v setVariable ['QS_TSS_turretL_locked',TRUE,TRUE];
		};
		if (_turret isEqualTo 2) then {
			[_v,['LMG_Minigun_Transport2',[2]]] remoteExec ['removeWeaponTurret',0,FALSE];
			_v setVariable ['QS_TSS_turretR_locked',TRUE,TRUE];
		};
		QS_TSS_turretControl = FALSE;
		QS_TSS_inturretloop = FALSE;
	};
";

QS_fnc_turretControl = compileFinal "
	private ['_v','_v2'];
	_v = vehicle player;
	QS_TSS_turretActions = [];
	{player removeAction _x;} count QS_TSS_turretActions;
	player removeAction QS_TSS_turretAction;
	if (isNil {_v getVariable 'QS_TSS_turretSafety'}) then {
		_v setVariable ['QS_TSS_turretSafety',TRUE,TRUE];
		_v setVariable ['QS_TSS_turretL_locked',FALSE,TRUE];
		_v setVariable ['QS_TSS_turretR_locked',FALSE,TRUE];
	};
	if (_v getVariable 'QS_TSS_turretL_locked') then {
		QS_TSS_turretLUnlockAction = player addAction [
			'Unlock Turret (Left)',
			QS_fnc_turretActions,
			[_v,1,0],
			80,
			FALSE,
			FALSE,
			'',
			'[] call QS_fnc_conditionTurretActionUnlockL'
		];
		0 = QS_TSS_turretActions pushBack QS_TSS_turretLUnlockAction;
	};
	if (_v getVariable 'QS_TSS_turretR_locked') then {
		QS_TSS_turretRUnlockAction = player addAction [
			'Unlock Turret (Right)',
			QS_fnc_turretActions,
			[_v,2,0],
			79,
			FALSE,
			FALSE,
			'',
			'[] call QS_fnc_conditionTurretActionUnlockR'
		];
		0 = QS_TSS_turretActions pushBack QS_TSS_turretRUnlockAction;
	};
	if (!(_v getVariable 'QS_TSS_turretL_locked')) then {
		QS_TSS_turretLLockAction = player addAction [
			'Lock Turret (Left)',
			QS_fnc_turretActions,
			[_v,1,1],
			78,
			FALSE,
			FALSE,
			'',
			'[] call QS_fnc_conditionTurretActionLockL'
		];
		0 = QS_TSS_turretActions pushBack QS_TSS_turretLLockAction;
	};
	if (!(_v getVariable 'QS_TSS_turretR_locked')) then {
		QS_TSS_turretRLockAction = player addAction [
			'Lock Turret (Right)',
			QS_fnc_turretActions,
			[_v,2,1],
			77,
			FALSE,
			FALSE,
			'',
			'[] call QS_fnc_conditionTurretActionLockR'
		];
		0 = QS_TSS_turretActions pushBack QS_TSS_turretRLockAction;
	};
	QS_TSS_turretActionCancel = player addAction [
		'Turret Safety (Cancel)',
		QS_fnc_turretActionCancel,
		[],
		76,
		FALSE,
		TRUE,
		'',
		''
	];
	0 = QS_TSS_turretActions pushBack QS_TSS_turretActionCancel;
	if (!(QS_TSS_inturretloop)) then {
		QS_TSS_inturretloop = TRUE;
		[_v] spawn {
			private ['_v','_v2'];
			_v = _this select 0;
			QS_TSS_turretControl = TRUE;
			while {QS_TSS_turretControl} do {
				_v2 = vehicle player;
				if ((!alive player) || {(!(player isEqualTo player))} || {(!(_v2 isEqualTo _v))}) then {
					QS_TSS_inturretloop = FALSE;
					QS_TSS_turretControl = FALSE;
					[_v,1,0] call QS_fnc_turretReset;
					[_v,2,0] call QS_fnc_turretReset;
				};
				sleep 0.5;
			};
			QS_TSS_turretAction = player addAction ['Turret Safety (Open)',QS_fnc_turretControl,[],-90,FALSE,FALSE,'','[] call QS_fnc_conditionTurretControl'];
		};
	};
";

QS_fnc_turretReset = compileFinal "
	private ['_v','_turret','_lock'];
	_v = _this select 0;
	_turret = _this select 1;
	_lock = _this select 2;
	QS_TSS_turretControl = FALSE;
	{player removeAction _x;} count QS_TSS_turretActions;
	if (_lock isEqualTo 0) exitWith {
		if (_turret isEqualTo 1) then {
			[_v,['LMG_Minigun_Transport',[1]]] remoteExec ['addWeaponTurret',0,FALSE];
			_v setVariable ['QS_TSS_turretL_locked',FALSE,TRUE];
		};
		if (_turret isEqualTo 2) then {
			[_v,['LMG_Minigun_Transport2',[2]]] remoteExec ['addWeaponTurret',0,FALSE];
			_v setVariable ['QS_TSS_turretR_locked',FALSE,TRUE];
		};	
	};
	if (_lock isEqualTo 1) exitWith {
		if (_turret isEqualTo 1) then {
			[_v,['LMG_Minigun_Transport',[1]]] remoteExec ['removeWeaponTurret',0,FALSE];
			_v setVariable ['QS_TSS_turretL_locked',TRUE,TRUE];
		};
		if (_turret isEqualTo 2) then {
			[_v,['LMG_Minigun_Transport2',[2]]] remoteExec ['removeWeaponTurret',0,FALSE];
			_v setVariable ['QS_TSS_turretR_locked',TRUE,TRUE];
		};
	};
";

QS_fnc_conditionTurretActionLockL = compileFinal "
	private ['_c','_v','_type'];
	_c = FALSE;
	_v = vehicle player;
	if ((typeOf _v) in QS_TSS_heliTypes) then {
		if (!(_v getVariable 'QS_TSS_turretL_locked')) then {
			_c = TRUE;
		};
	};
	_c;	
";

QS_fnc_conditionTurretActionLockR = compileFinal "
	private ['_c','_v','_type'];
	_c = FALSE;
	_v = vehicle player;
	if ((typeOf _v) in QS_TSS_heliTypes) then {
		if (!(_v getVariable 'QS_TSS_turretR_locked')) then {
			_c = TRUE;
		};
	};
	_c;
";

QS_fnc_conditionTurretActions = compileFinal "
	private ['_c','_v','_type'];
	_c = TRUE;
	_v = vehicle player;
	if ((typeOf _v) in QS_TSS_heliTypes) then {
		if (player isEqualTo (effectiveCommander _v)) then {
			_c = TRUE;
		};
	};
	_c;
";

QS_fnc_conditionTurretActionUnlockL = compileFinal "
	private ['_c','_v','_type'];
	_c = FALSE;
	_v = vehicle player;
	if ((typeOf _v) in QS_TSS_heliTypes) then {
		if (_v getVariable 'QS_TSS_turretL_locked') then {
			_c = TRUE;
		};
	};
	_c;
";

QS_fnc_conditionTurretActionUnlockR = compileFinal "
	private ['_c','_v','_type'];
	_c = FALSE;
	_v = vehicle player;
	if ((typeOf _v) in QS_TSS_heliTypes) then {
		if (_v getVariable 'QS_TSS_turretR_locked') then {
			_c = TRUE;
		};
	};
	_c;
";

QS_fnc_conditionTurretControl = compileFinal "
	private ['_c','_v','_type'];
	_c = FALSE;
	_v = vehicle player;
	if ((typeOf _v) in QS_TSS_heliTypes) then {
		if (player isEqualTo (effectiveCommander _v)) then {
			_c = TRUE;
		};
	};
	_c;
";

QS_TSS_ehRespawnTurretSafety = player addEventHandler [
	'Respawn',
	{
		QS_TSS_inturretloop = FALSE;
		QS_TSS_turretAction = player addAction ['Turret Safety (Open)',QS_fnc_turretControl,[],-90,FALSE,FALSE,'','[] call QS_fnc_conditionTurretControl'];
	}
];

QS_TSS_inturretloop = FALSE;
QS_TSS_turretAction = player addAction ['Turret Safety (Open)',QS_fnc_turretControl,[],-90,FALSE,FALSE,'','[] call QS_fnc_conditionTurretControl'];