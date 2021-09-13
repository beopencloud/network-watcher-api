package main

import (
	"encoding/base64"
	"encoding/json"
	"github.com/beopencloud/network-watcher-api-mock/env"
	"io"
	"io/ioutil"

	"log"
	"net/http"
	"strings"
	//	"github.com/beopencloud/network-watcher-api-mock/event"
	//"k8s.io/client-go/dynamic"
	//"k8s.io/client-go/kubernetes"

)

func main() {

	// public views
	http.HandleFunc("/", HandleIndex)

	// private views
	http.HandleFunc("/service/post", PostOnly(BasicAuth(HandlePost)))
	http.HandleFunc("/service/put", PutOnly(BasicAuth(HandlePut)))
	http.HandleFunc("/service/delete", DeleteOnly(BasicAuth(HandleDelete)))

	log.Fatal(http.ListenAndServe(":80", nil))

}

type handler func(w http.ResponseWriter, r *http.Request)

func BasicAuth(pass handler) handler {
	return func(w http.ResponseWriter, r *http.Request) {
		auth := strings.SplitN(r.Header.Get("Authorization"), " ", 2)
		if len(auth) != 2 || auth[0] != "Basic" {
			http.Error(w, "authorization failed", http.StatusUnauthorized)
			return
		}

		payload, _ := base64.StdEncoding.DecodeString(auth[1])
		pair := strings.SplitN(string(payload), ":", 2)

		if len(pair) != 2 || !validate(pair[0], pair[1]) {
			http.Error(w, "authorization failed", http.StatusUnauthorized)
			return
		}

		pass(w, r)
	}
}

func validate(username, password string) bool {
	if username == env.USERNAME && password == env.PASSWORD {
		return true
	}
	return false
}

func HandleIndex(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "hello, world\n")
}

func HandlePost(w http.ResponseWriter, r *http.Request) {
	log.Println("=======  =====")
	log.Println("CREATE EVENT")
	res, _ := ioutil.ReadAll(r.Body)
	ParsingData(res)
	io.WriteString(w, "post\n")
	return

	return
}

func exitOnErr(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

func HandlePut(w http.ResponseWriter, r *http.Request) {
	log.Println("=============")
	log.Println("UPDATE EVENT")
	res, _ := ioutil.ReadAll(r.Body)
	io.WriteString(w, "post\n")
	ParsingData(res)

}

func HandleDelete(w http.ResponseWriter, r *http.Request) {
	log.Println("============")
	log.Println("DELETE EVENT")
	res, _ := ioutil.ReadAll(r.Body)
	ParsingData(res)

}

type Result struct {
	FirstName string `json:"first"`
	LastName  string `json:"last"`
}

func HandleJSON(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	result, _ := json.Marshal(Result{"tee", "dub"})
	io.WriteString(w, string(result))
}

func GetOnly(h handler) handler {

	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" {
			h(w, r)
			return
		}
		http.Error(w, "get only", http.StatusMethodNotAllowed)
	}
}

func PostOnly(h handler) handler {

	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "POST" {
			h(w, r)
			return
		}
		http.Error(w, "post only", http.StatusMethodNotAllowed)
	}
}

func PutOnly(h handler) handler {

	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "PUT" {
			h(w, r)
			return
		}
		http.Error(w, "put only", http.StatusMethodNotAllowed)
	}
}

func DeleteOnly(h handler) handler {

	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "DELETE" {
			h(w, r)
			return
		}
		http.Error(w, "delete only", http.StatusMethodNotAllowed)
	}
}

// This function allow to retrieve data sended by the operator

func ParsingData(data []byte) {
	var birdJson = string(data)
	var result map[string]interface{}
	json.Unmarshal([]byte(birdJson), &result)
	metadata := result["metadata"].(map[string]interface{})
	spec := result["spec"].(map[string]interface{})
	log.Println("Name: ", metadata["name"].(string))
	log.Println("Namespace: ", metadata["namespace"].(string))
	log.Println("Type: ", spec["type"].(string))
	var pspec map[string]interface{}
	_ = json.Unmarshal([]byte(birdJson), &pspec)
	for _, v := range pspec {
		for key, value := range v.(map[string]interface{}) {
			if key == "loadBalancer" {
				for kk, vv := range value.(map[string]interface{}) {
					if kk == "ingress" {
						for _, vip := range vv.([]interface{}) {
							vs := vip.(map[string]interface{})
							log.Println("IP: ", vs["ip"])

						}
					}
				}
			}
		}
	}
}
