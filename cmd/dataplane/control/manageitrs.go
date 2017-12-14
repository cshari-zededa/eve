package main

import (
	"fmt"
	"github.com/google/gopacket/pfring"
	"github.com/zededa/go-provision/dataplane/itr"
)

type ThreadEntry struct {
	channel chan bool
	ring   *pfring.Ring
}

var threadTable map[string]ThreadEntry

func InitThreadTable() {
	threadTable = make(map[string]ThreadEntry)
}

func DumpThreadTable() {
	for name, _ := range threadTable {
		fmt.Println(name)
	}
}

func ManageItrThreads(interfaces Interfaces) {
	tmpMap := make(map[string]bool)

	// Build a map of threads needed according to new configuration
	for _, iface := range interfaces.Interfaces {
		tmpMap[iface.Interface] = true
	}

	// Kill ITR threads that are not needed with new configuration
	//for name, channel := range threadTable {
	for name, entry := range threadTable {
		// Check if this thread is needed with new configuration and send
		// a kill signal if not.
		if _, ok := tmpMap[name]; !ok {
			// This thread has to die, break the bad news to it
			fmt.Println("Sending kill signal to", name)
			entry.channel <- true

			// XXX
			// Should we wait for the thread to actually exit?
			// What would happen if the channel gets GC'd before the thread can read?
			// Close the channel also.
			close(entry.channel)
			entry.ring.Disable()
			entry.ring.Close()
			delete(threadTable, name)
		}
	}

	// Create new threads that do not already exist
	for name, _ := range tmpMap {
		if _, ok := threadTable[name]; !ok {
			// This ITR thread has to be given birth to. Find a mom!!
			killChannel := make(chan bool, 1)

			// XXX
			// Start the go thread here
			ring := itr.SetupPacketCapture(name, 65536)
			fmt.Println("Creating new ITR thread for", name)
			threadTable[name] = ThreadEntry{
				channel: killChannel,
				ring: ring,
			}
			go itr.StartItrThread(name, ring, killChannel, puntChannel)
		}
	}
}
