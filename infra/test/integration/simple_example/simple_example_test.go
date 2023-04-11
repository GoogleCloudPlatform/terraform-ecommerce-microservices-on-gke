// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package simple_example

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
)

// Retry if these errors are encountered.
var retryErrors = map[string]string{}

func TestSimpleExample(t *testing.T) {
	example := tft.NewTFBlueprintTest(t)

	example.DefineVerify(func(assert *assert.Assertions) {
		projectId := example.GetTFSetupStringOutput("project_id")
		deploymentIpAddr := example.GetStringOutput("deployment_ip_address")
		deploymentUrl := fmt.Sprintf("http://%s", deploymentIpAddr)
		testDeploymentUrl(t, assert, deploymentUrl)
		testGoogleCloudApis(t, assert, projectId)
	})

	example.Test()
}

func testDeploymentUrl(t *testing.T, assert *assert.Assertions, url string) error {
	for attemptNum := 1; attemptNum <= 60; attemptNum++ {

		// Failed request.
		response, err := http.Get(url)
		if err != nil {
			t.Logf("Deployment URL HTTP request error: %s\n", err)

		} else if 200 <= response.StatusCode && response.StatusCode <= 299 { // Got some 200 responses.
			responseBody, err := ioutil.ReadAll(response.Body)
			if err != nil {
				return err
			}
			t.Logf(string(responseBody)) // TODO: Delete this line!
			assert.Containsf(responseBody, "us-west1", "couldn't find text 'us-west1' in deployment's response")
			assert.Containsf(responseBody, "Cymbal Shops", "Couldn't find text 'Cymbal Shops' in deployment's response")
			return nil

		} else { // Got a non-200 response.
			t.Logf("Deployment URL responded with status code: %d.\n", response.StatusCode)
		}

		// Wait before retrying.
		time.Sleep(4 * time.Second)
	}

	t.Logf("Waited too long for deployment URL.\n")
	return nil
}

func testGoogleCloudApis(t *testing.T, assert *assert.Assertions, projectId string) {
	serviceTests := map[string]struct {
		service string
	}{
		"Service container":                    {service: "container"},
		"Service dns":                          {service: "dns"},
		"Service gkehub":                       {service: "gkehub"},
		"Service multiclusteringress":          {service: "multiclusteringress"},
		"Service multiclusterservicediscovery": {service: "multiclusterservicediscovery"},
		"Service trafficdirector":              {service: "trafficdirector"},
	}
	services := gcloud.Run(t, "services list", gcloud.WithCommonArgs([]string{"--project", projectId, "--format", "json"})).Array()
	for _, tc := range serviceTests {
		t.Run(tc.service, func(t *testing.T) {
			match := utils.GetFirstMatchResult(t, services, "config.name", fmt.Sprintf("%s.googleapis.com", tc.service))
			assert.Equal("ENABLED", match.Get("state").String(), "%s service should be enabled", tc.service)
		})
	}
}
