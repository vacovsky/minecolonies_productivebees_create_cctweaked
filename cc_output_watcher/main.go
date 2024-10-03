package main

import (
	"log"

	"github.com/fsnotify/fsnotify"
)

var WATCHED_FILES = []string{
	// Nolins
	`/home/amp/.ampdata/instances/FarmColonies01/Minecraft/world/computercraft/computer/14/monitorData.json`,
	`/home/amp/.ampdata/instances/FarmColonies01/Minecraft/world/computercraft/computer/6/monitorData.json`,
	`/home/amp/.ampdata/instances/FarmColonies01/Minecraft/world/computercraft/computer/8/prunerData.json`,
	`/home/amp/.ampdata/instances/FarmColonies01/Minecraft/world/computercraft/computer/8/incineratorData.json`,
	`/home/amp/.ampdata/instances/FarmColonies01/Minecraft/world/computercraft/computer/8/warehouseVacuum.json`,
	`/home/amp/.ampdata/instances/FarmColonies01/Minecraft/world/computercraft/computer/6/honeyPowerData.json`,
	`/home/amp/.ampdata/instances/FarmColonies01/Minecraft/world/computercraft/computer/6/foodHoney.json`,
	`/home/amp/.ampdata/instances/FarmColonies01/Minecraft/world/computercraft/computer/15/bulletUse.json`,
	`/home/amp/.ampdata/instances/FarmColonies01/Minecraft/world/computercraft/computer/17/xp_drain_1.json`,

	// Sea Shanty
	// `/home/amp/.ampdata/instances/FarmColonies01/Minecraft/world/computercraft/computer/4/monitorData.json`,
	`/home/amp/.ampdata/instances/FarmColonies01/Minecraft/world/computercraft/computer/9/monitorData.json`,
}

func main() {

	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		log.Fatal("NewWatcher failed: ", err)
	}
	defer watcher.Close()

	done := make(chan bool)
	go func() {
		defer close(done)

		for {
			select {
			case event, ok := <-watcher.Events:
				if !ok {
					return
				}
				// file change detected
				log.Printf("%s %s\n", event.Name, event.Op)
				// read in file to JSON
				// jsonFile, err := os.Open("users.json")
				if event.Op == fsnotify.Write {
					ingestMonitorDataToRedis(event.Name)
				}
			case err, ok := <-watcher.Errors:
				if !ok {
					return
				}
				log.Println("error:", err)
			}
		}

	}()

	for _, file := range WATCHED_FILES {

		err = watcher.Add(file)
	}
	if err != nil {
		log.Fatal("Add failed:", err)
	}
	<-done

}
