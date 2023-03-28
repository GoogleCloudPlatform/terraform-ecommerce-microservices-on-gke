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
	"testing"

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
		example.DefaultVerify(assert)
		projectId := example.GetTFSetupStringOutput("project_id")
		// TODO: Test the deploymentIpAddress.
		// deploymentIpAddress := example.GetStringOutput("deployment_ip_address")

		// Test that GCP APIs have been enabled.
		// TODO: Change this serviceTests in an array of strings.
		serviceTests := map[string]struct {
			service string
		}{
			"Service comcloudresourcemanager":      {service: "comcloudresourcemanager"},
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
	})

	example.Test()
}
