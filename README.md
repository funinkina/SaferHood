# SaferHood

SaferHood is an advanced crime prediction and preventive policing system designed to enhance public safety and reduce crime rates through the integration of machine learning algorithms and comprehensive data analysis. Leveraging historical crime data, socio-economic factors, real-time social media feeds, and cutting-edge technologies, SaferHood provides law enforcement agencies with actionable insights to optimize resource allocation and proactively address criminal activities

## [SaferHood Web App](https://saferhood.pythonanywhere.com)

https://saferhood.pythonanywhere.com
SaferHood offers both a web and iOS application designed to provide law enforcement agencies with essential tools for crime prediction, resource allocation, and proactive policing. Here's how each platform contributes to enhancing public safety:

Demo Videos:
https://drive.google.com/drive/folders/1gOLj5ihSVnrbu2DLfNwEDy395vBf_i4D

**Web Application Features:**

1.  **Hotspot Mapping:**
- Generates hotspot maps to identify high-risk areas and potential crime patterns.
- Utilizes FIR records, criminal records, and real-time patrol locations for accurate predictions.
2.  **Victim Prediction:**
- Predicts individuals and areas at a heightened risk of becoming crime victims.
- Utilizes victim data and situational factors for proactive measures to safeguard vulnerable community members.
3.  **Live News Data:**
- Integrates real-time updates from diverse news sources, providing immediate insights into emerging events and potential threats. 
- This feature enhances situational awareness and aids in timely decision-making.
4.  **Repeat Offender Prediction:**
- Predicts the likelihood of known offenders recommitting crimes based on comprehensive data analysis.
- Supports proactive interventions to prevent repeat offenses using criminal records and historical data.

**iOS Application Features:**

1.  **Live Patrol Location:**
- Allows users to track the live location of patrol units in real-time. This feature optimizes resource deployment by enabling law enforcement agencies to monitor patrol movements and allocate resources efficiently.
2.  **Suspected Perpetrators:**
- Provides information on suspected criminal groups or individuals based on predictive models. On-duty patrol officers can use this information to track and apprehend criminals more effectively.

By combining these features across both web and iOS platforms, SaferHood empowers law enforcement agencies with comprehensive tools for crime prediction, prevention, and proactive policing. The integration of data analysis, real-time updates, and predictive models enhances situational awareness and enables strategic decision-making to create safer communities.


## **Technology Used:**

-   Machine Learning: Scikit Learn, PyTorch
-   Natural Language Processing: spaCy
-   Data Analysis: Python (Pandas, NumPy)
-   Database: MongoDB
-   Web Scraping: BeautifulSoup, Tweepy
-   Visualization: GeoPandas, Matplotlib
-   Deployment: Flask, HTML, Pythonanywhere
-   iOS Application: Swift

## Models used

SaferHood employs a diverse range of machine learning techniques tailored to specific functionalities within the system. For hotspot mapping, the utilization of LSTM (Long Short-Term Memory) models allows for the accurate prediction of crime hotspots over various time ranges, providing law enforcement agencies with valuable insights into areas of heightened criminal activity. In victim prediction, sophisticated data analysis methods are employed to analyze victim profiles and situational factors, enabling the proactive identification of individuals and areas at increased risk of crime. Furthermore, the use of Random Forest algorithms for criminal prediction enhances the system's ability to identify potential perpetrators based on comprehensive data analysis, aiding law enforcement in effectively targeting repeat offenders. By leveraging these advanced machine learning approaches in tandem with robust data analysis techniques, SaferHood equips law enforcement agencies with powerful tools for crime prediction, prevention, and proactive policing, ultimately contributing to the creation of safer communities.
