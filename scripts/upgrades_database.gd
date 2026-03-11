extends Node

const icon_path = "res://assets/attacks/"

const upgrades = {
	"firewall1": {
		"icon": icon_path + "fireball.png",
		"name": "Firewall Peppering",
		"description": "Shoots a fireball that explodes on contact.",
		"level": "Level 1",
		"prerequisite": [],
		"type": "attack"
	},
	"firewall2": {
		"icon": icon_path + "fireball.png",
		"name": "Firewall Peppering",
		"description": "Increases fireball size. Increases damage dealt.",
		"level": "Level 2",
		"prerequisite": ["firewall1"],
		"type": "attack"
	},
	"firewall3": {
		"icon": icon_path + "fireball.png",
		"name": "Firewall Peppering",
		"description": "Increases fireball size. Increases damage dealt.",
		"level": "Level 3",
		"prerequisite": ["firewall2"],
		"type": "attack"
	},
	"cyclone1": {
		"icon": icon_path + "cyclone.png",
		"name": "DDOS Cyclone",
		"description": "Shoots 2 cyclones that knock enemies back.",
		"level": "Level 1",
		"prerequisite": [],
		"type": "attack"
	},
	"cyclone2": {
		"icon": icon_path + "cyclone.png",
		"name": "DDOS Cyclone",
		"description": "Adds an additional cyclone. Increases damage dealt.",
		"level": "Level 2",
		"prerequisite": ["cyclone1"],
		"type": "attack"
	},
	"cyclone3": {
		"icon": icon_path + "cyclone.png",
		"name": "DDOS Cyclone",
		"description": "Adds an additional cyclone. Increases damage dealt.",
		"level": "Level 3",
		"prerequisite": ["cyclone2"],
		"type": "attack"
	},
	"orbital1": {
		"icon": icon_path + "sword.png",
		"name": "Artemis Orbital",
		"description": "Creates a sword orbiting around Anoop.",
		"level": "Level 1",
		"prerequisite": [],
		"type": "attack"
	},
	"orbital2": {
		"icon": icon_path + "sword.png",
		"name": "Artemis Orbital",
		"description": "Adds an additional sword.",
		"level": "Level 2",
		"prerequisite": ["orbital1"],
		"type": "attack"
	},
	"orbital3": {
		"icon": icon_path + "sword.png",
		"name": "Artemis Orbital",
		"description": "Adds an additional sword.",
		"level": "Level 3",
		"prerequisite": ["orbital2"],
		"type": "attack"
	},
	"armor1": {
		"icon": icon_path + "shower.png",
		"name": "Monthly Shower",
		"description": "Increases armor by 1.",
		"level": "Level 1",
		"prerequisite": [],
		"type": "buff"
	},
	"armor2": {
		"icon": icon_path + "shower.png",
		"name": "Monthly Shower",
		"description": "Increases armor by 1.",
		"level": "Level 2",
		"prerequisite": ["armor1"],
		"type": "buff"
	},
	"armor3": {
		"icon": icon_path + "shower.png",
		"name": "Monthly Shower",
		"description": "Increases armor by 2.",
		"level": "Level 3",
		"prerequisite": ["armor2"],
		"type": "buff"
	},
	"armor4": {
		"icon": icon_path + "shower.png",
		"name": "Monthly Shower",
		"description": "Increases armor by 2.",
		"level": "Level 4",
		"prerequisite": ["armor3"],
		"type": "buff"
	},
	"food": {
		"icon": icon_path + "food.png",
		"name": "Food",
		"description": "Heals Anoop for 60 health.",
		"level": "N/A",
		"prerequisite": [],
		"type": "item"
	}, 
	"gun1": {
		"icon": icon_path,
		"name": "Gun",
		"description": "Upgrades Anoop's gun",
		"level": "Level 1",
		"prerequisite": [],
		"type": "attack",
	},
	"gun2": {
		"icon": icon_path,
		"name": "Gun",
		"description": "Upgrades Anoop's gun",
		"level": "Level 2",
		"prerequisite": ["gun1"],
		"type": "attack"
	},
	"gun3": {
		"icon": icon_path,
		"name": "Gun",
		"description": "Upgrades Anoop's gun",
		"level": "Level 3",
		"prerequisite": ["gun2"],
		"type": "attack"
	}
}
