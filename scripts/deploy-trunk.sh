# isolate our environment
mkdir $ENV
cd $ENV

# set up registry apps
svn co https://gbif-labs.googlecode.com/svn/registry2/trunk registry
cd registry
mvn clean package -DskipTests -P$ENV-portal -s ../../$ENV-settings.xml
cd registry-ws 
mvn cargo:redeploy -P$ENV-portal -Dcargo.context=registry2-ws -s ../../../$ENV-settings.xml
cd ../../
# test urls
# http://jawa.gbif.org:8080/registry-search-ws/search?type=OCCURRENCE
# http://jawa.gbif.org:8080/registry-solr/collection1/select?q=*%3A*&wt=xml&indent=true
# http://jawa.gbif.org:8080/registry-ws/dataset

# set up checklistbank apps
svn co https://gbif-ecat.googlecode.com/svn/checklistbank/trunk checklistbank
cd checklistbank
mvn clean package -DskipTests -P$ENV-portal -s ../../$ENV-settings.xml
cd checklistbank-ws 
mvn cargo:redeploy -P$ENV-portal -Dcargo.context=checklistbank-ws -s ../../../$ENV-settings.xml
cd ../checklistbank-search-ws 
mvn cargo:redeploy -P$ENV-portal -Dcargo.context=checklistbank-search-ws -s ../../../$ENV-settings.xml
cd ../../
# test urls
# http://jawa.gbif.org:8080/checklistbank-search-ws/search?q=Puma
# http://jawa.gbif.org:8080/checklistbank-solr/collection1/select?q=scientific_name:puma
# http://jawa.gbif.org:8080/checklistbank-ws/species/1

# set up occurrence apps
svn co https://gbif-occurrencestore.googlecode.com/svn/occurrence/trunk occurrence
cd occurrence
mvn clean package -DskipTests -P$ENV-portal -s ../../$ENV-settings.xml
cd occurrence-ws 
mvn cargo:redeploy -P$ENV-portal -Dcargo.context=occurrence-ws -s ../../../$ENV-settings.xml
cd ../occurrence-search-ws 
mvn cargo:redeploy -P$ENV-portal -Dcargo.context=occurrence-ws -s ../../../$ENV-settings.xml
cd ../../
# test urls
# http://jawa.gbif.org:8080/occurrence-ws/occurrence/search
# http://jawa.gbif.org:8080/occurrence-solr/collection1/select?q=*%3A*&wt=xml&indent=true
# http://jawa.gbif.org:8080/occurrence-ws/occurrence/1000000 (1000000 might get deleted, so it needs to be a valid ID)

# set up occurrence download apps
svn co https://gbif-occurrencestore.googlecode.com/svn/occurrence-download/trunk occurrence-download
cd occurrence-download
mvn clean package -DskipTests -P$ENV-occurrence-download-ws -s ../../$ENV-settings.xml
cd occurrence-download-ws 
mvn cargo:redeploy -P$ENV-occurrence-download-ws -Dcargo.context=occurrence-download-ws -s ../../../$ENV-settings.xml
#set up occurrence download oozie workflow
cd ..
cd occurrence-download-workflow
mvn -P$ENV-occurrence-download-workflow clean package assembly:single -s ../../../$ENV-settings.xml
hadoop dfs -rm -r /occurrence-download/$ENV
hadoop dfs -put target/occurrence-download-workflow-0.7-SNAPSHOT-oozie /occurrence-download/$ENV
cd ../../


# test urls
# http://jawa.gbif.org:8080/occurrence-download-ws/occurrence/download

# set up metrics ws
svn co https://gbif-metrics.googlecode.com/svn/metrics/trunk metrics
cd metrics
mvn clean package -DskipTests -P$ENV-portal -s ../../$ENV-settings.xml
cd metrics-ws 
mvn cargo:redeploy -P$ENV-portal -Dcargo.context=metrics-ws -s ../../../$ENV-settings.xml
cd ../../
# test urls
# http://jawa.gbif.org:8080/metrics-ws/occurrence/count

# set up tile-server
svn co https://gbif-portal.googlecode.com/svn/tile-server/trunk tile-server
cd tile-server
mvn clean package cargo:redeploy -P$ENV-portal -Dcargo.context=tile-server -s ../../$ENV-settings.xml
cd ../../
# test urls
# http://jawa.gbif.org:8080/tile-server/density/tile?key=1&x=0&y=0&z=0&type=TAXON

# deploy the portal
svn co https://gbif-portal.googlecode.com/svn/portal-web/trunk portal-web
cd portal-web
mvn clean package cargo:redeploy -P$ENV,$ENV-portal-web -Dcargo.context=portal -DskipTests -s ../../$ENV-settings.xml