/**
 * Copyright 2015 Novartis Institutes for BioMedical Research Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * 
 */
package com.novartis.opensource.yada.test;

import java.net.HttpURLConnection;

import org.apache.log4j.Logger;
import org.testng.annotations.Test;

import com.novartis.opensource.yada.Service;
import com.novartis.opensource.yada.YADAExecutionException;
import com.novartis.opensource.yada.YADAQueryConfigurationException;
import com.novartis.opensource.yada.format.YADAResponseException;

/**
 * This is a stubbed class to get you started with internal-only tests.
 * Obviously you can be as elaborate as you want with internal testing. Refer to
 * the superclass {@link com.novartis.opensource.yada.test.ServiceTest} for more
 * examples.
 * 
 * @author David Varon
 * 
 */
public class InternalServiceTest extends ServiceTest {

  /**
   * Local logger handle
   */
  @SuppressWarnings("unused")
  private static Logger l = Logger.getLogger(InternalServiceTest.class);

  /**
   * A sample test method. Add your own tests to the /test/internal.txt file to
   * execute. Add more methods and tests!
   * 
   * Refer to the superclass
   * {@link com.novartis.opensource.yada.test.ServiceTest} for more examples.
   * 
   * @param query the query to execute
   * @throws YADAQueryConfigurationException when request creation fails
   * @throws YADAExecutionException when the test fails
   * @throws YADAResponseException when the response is malformed 
   */
  @Test(dataProvider = "QueryTests", groups = { "internal" })
  @QueryFile(list = { "/test/internal.txt" })
  public void testInternal(String query) throws YADAQueryConfigurationException, YADAExecutionException, YADAResponseException 
  {
      Service svc = prepareTest(query);
      validateJSONResult(svc.execute());
  }

  /**
   * Use this overridden method to implement a scheme for authenticated tests.  Typically this would involve 
   * retrieving a cookie and then setting it on the connection used for the HTTP request comprising the test.
   */
  @Override
  public void setAuthentication(HttpURLConnection connection) throws YADAExecutionException
  {
    // implement your authentication scheme here for authenticated tests
  }
}