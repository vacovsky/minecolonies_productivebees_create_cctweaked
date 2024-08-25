package main

import (
	"log"

	"github.com/fsnotify/fsnotify"
)

var WATCHED_FILES = []string{
	`D:\FarmColonies\world\computercraft\computer\4\monitorData.json`,
	`D:\FarmColonies\world\computercraft\computer\6\monitorData.json`,
	// `D:\FarmColonies\world\computercraft\computer\4\monitorData.json`,
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
