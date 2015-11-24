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