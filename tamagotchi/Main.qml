import QtQuick

QtObject {
    id: root
		property var pluginApi: null

		readonly property var cfg: pluginApi?.pluginSettings ?? ({})

    property int hunger:      cfg.hunger      ?? 100
    property int happiness:   cfg.happiness   ?? 100
    property int cleanliness: cfg.cleanliness ?? 100
    property int energy:      cfg.energy      ?? 100

		property bool _sleeping: false
		property bool eating: false
		property string lastPetState: "idle"
		readonly property string petState: {
				if (root._sleeping && energy > 98)
						return lastPetState

				if (root._sleeping)
						return "sleeping"

				const isSad    = happiness   < 30
				const isTired  = energy      < 30
				const isDirty  = cleanliness < 20
				const isHungry = hunger      < 20

				if (isSad && (isHungry || isTired))
						return "angry"
				else if (isHungry)
						return "hungry"
				else if (isDirty)
						return "dirty"
				else if (isSad)
						return "sad"
				else if (isTired)
						return "tired"
				else
						return "idle"
		}

		function save() {
			if (!pluginApi) return
        pluginApi.pluginSettings.hunger      = hunger
        pluginApi.pluginSettings.happiness   = happiness
        pluginApi.pluginSettings.cleanliness = cleanliness
        pluginApi.pluginSettings.energy      = energy
        pluginApi.saveSettings()
    }

		function sleep() {
			if (root._sleeping) {
				root._sleeping = false
			} else {
				lastPetState = petState
				root._sleeping = true
			}
			save()
		}

		function clean(c) {
			cleanliness = Math.min(100, cleanliness + c)
			save()
		}
		
		function feed(v) {
			hunger = Math.min(100, hunger + v)
			save()
		}

		function play(h,e = 15) {
			if (energy < 10) return
			happiness   = Math.min(100, happiness + h)
			energy      = Math.max(0, energy - e)
			save()
		}

		function decay() {
				if (root._sleeping) {
						energy      = Math.min(100, energy + 15)
						hunger      = Math.max(0, hunger - 0.3)
						happiness   = Math.max(0, happiness - 0.2)
						cleanliness = Math.max(0, cleanliness - 0.2)
				} else {
						hunger      = Math.max(0, hunger - 0.7)
						happiness   = Math.max(0, happiness - 0.3)
						cleanliness = Math.max(0, cleanliness - 0.5)
						energy      = Math.max(0, energy - 0.4)
				}

				save()
		}
}
