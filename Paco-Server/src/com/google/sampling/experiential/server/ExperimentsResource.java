/*
 * Copyright 2012 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */

package com.google.sampling.experiential.server;

import com.google.sampling.experiential.shared.Experiment;

import org.restlet.data.Status;
import org.restlet.resource.Get;
import org.restlet.resource.Post;


/**
 *
 * @author corycornelius@google.com (Cory Cornelius)
 *
 */
public class ExperimentsResource extends PacoResource {
  @Get("json|gwt")
  public Object show() {
    return dao.getSubjectExperiments(user);
  }

  @Post("gwt|json")
  public void create(Experiment experiment) {
    Long experimentId = dao.createExperiment(experiment);

    redirectSeeOther("/observer/experiments/" + experimentId);
    setStatus(Status.SUCCESS_CREATED);
  }
}
