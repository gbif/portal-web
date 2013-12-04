# copy the metadata from staging to $ENV
scp -r root@staging:/usr/local/share/registry-metadata/metadata .
scp -r metadata/* root@jawa:/var/local/large/metadata

#Occurrence solr index was built on jawa //mnt/ssd/solr/occurrence-index-builder/solr
#Create a backup of the occurrence index
ssh root@jawa 'mv //mnt/ssd/solr/occurrence-solr //var/local/large/solr/occurrence-solr$(date +"%b-%d-%Y")'
ssh root@jawa 'mv //mnt/ssd/solr/occurrence-index-builder/solr //mnt/ssd/solr/occurrence-solr'