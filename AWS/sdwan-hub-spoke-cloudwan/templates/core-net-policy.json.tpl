{
	"version": "2021.12",
	"core-network-configuration": {
		"vpn-ecmp-support": true,
		"asn-ranges": [
			"65010-65030"
		],
		"edge-locations": [
			{
				"location": "us-west-2",
				"asn": 65022
			},
			{
				"location": "eu-west-2",
				"asn": 65012
			}
		]
	},
	"segments": [
		{
			"name": "Trusted",
			"require-attachment-acceptance": false
		},
		{
			"name": "Untrusted",
			"require-attachment-acceptance": false,
			"isolate-attachments": true
		}
	],
	"segment-actions": [
		{
			"action": "create-route",
			"segment": "Untrusted",
			"destination-cidr-blocks": [
				"0.0.0.0/0"
			],
			"destinations": [
				"${sdwan-vpc-attachment}"
			]
		},
		{
			"action": "share",
			"mode": "attachment-route",
			"segment": "Trusted",
			"share-with": [
				"Untrusted"
			]
		}
	],
	"attachment-policies": [
		{
			"rule-number": 100,
			"conditions": [
				{
					"type": "tag-value",
					"operator": "equals",
					"key": "segment",
					"value": "Trusted"
				}
			],
			"action": {
				"association-method": "constant",
				"segment": "Trusted"
			}
		},
		{
			"rule-number": 200,
			"conditions": [
				{
					"type": "tag-value",
					"operator": "equals",
					"key": "segment",
					"value": "Untrusted"
				}
			],
			"action": {
				"association-method": "constant",
				"segment": "Untrusted"
			}
		}
	]
}