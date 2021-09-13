package env

import (
	"fmt"
	"github.com/joho/godotenv"
	"log"
	"os"
	"path/filepath"
	"strconv"
)

const (
	NetworkWatcherNamespaceLabelKey   = "intrabpce.fr/network-watching"
	NetworkWatcherNamespaceLabelValue = "true"
)

var (
	USERNAME   = "test"
	PASSWORD   = "test"
	IN_CLUSTER = false
	KUBECONFIG = filepath.Join(homeDir(), ".kube", "config")
)

func init() {
	err := godotenv.Load()
	if err != nil {
		err := godotenv.Load("./../../.env")
		if err != nil {
			log.Println("")
		}
	}

	USERNAME = getStringValue("USERNAME", USERNAME)
	PASSWORD = getStringValue("PASSWORD", PASSWORD)

	KUBECONFIG = getStringValue("KUBECONFIG", KUBECONFIG)
	IN_CLUSTER = getBoolValue("IN_CLUSTER", IN_CLUSTER)

	fmt.Println("env loaded")
}

func getBoolValue(key string, defaultValue bool) bool {

	if len(os.Getenv(key)) == 0 {
		return defaultValue
	}
	val, err := strconv.ParseBool(os.Getenv(key))
	if err != nil {
		log.Fatal("Error ", key, " must be a boolean. default value ", defaultValue, " is loaded")
		return defaultValue
	}
	return val
}

func getStringValue(key string, defaultValue string) string {
	if len(os.Getenv(key)) == 0 {
		return defaultValue
	}
	return os.Getenv(key)
}

func homeDir() string {
	if h := os.Getenv("HOME"); h != "" {
		return h
	}
	return os.Getenv("USERPROFILE") // windows
}
