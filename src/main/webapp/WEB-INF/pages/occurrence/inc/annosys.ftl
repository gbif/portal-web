<#-- Annosys modal and button but only if it is from the publisher http://www.bgbm.org -->
    <#assign institutionCode = action.termValue('institutionCode')! />
    <#assign collectionCode = action.termValue('collectionCode')! />
    <#assign catalogNumber =  action.termValue('catalogNumber')! />
    <#assign publishingOrgKey = occ.publishingOrgKey! />

<#-- For now only show the annosys integration if it is published by BGBM aka the Botanic Garden and Botanical Museum Berlin-Dahlem -->
<#if publishingOrgKey == "57254bd0-8256-11d8-b7ed-b8a03c50a862">
    <a id="annosysTrigger" href="#" class="annosys">AnnoSys <span class="annosysCount"></span></a>
    <div id="annosysBlanket" class="atlwdg-blanket annosysBlanket"></div>
    <div id="annosysModal" class="atlwdg-box-shadow annosysModal">
        <h2>AnnoSys</h2>
        <div class="annosysModal__content">
            <img src="//annosys.bgbm.fu-berlin.de/sites/default/files/AnnoSys_update.png">
            <p>
                Through this pilot integration, you can make use of the AnnoSys system developed by the <a href="http://www.bgbm.org/">Botanic Garden and Botanical Museum Berlin-Dahlem</a> to create annotations about this record.
            </p>
            <p>
                Currently GBIF do not store, or harvest the annotations created and do not take responsibility for annotations created through it.
            </p>
            <div id="existingAnnotations" class="existingAnnotations">
                <h3>
                    This record has <span class="annosysCount"></span> existing annotations
                </h3>
                <ul id="annotations">
                </ul>
            </div>
        </div>
        <footer>
            <a href="#" target="_blank" class="annosys__annotate button">Annotate</a>
            <a href="#" class="cancel">Close</a>
        </footer>
    </div>

    <script>
        $(document).ready(function () {

            //rewrite enums a la ZoologicalScientificName to Zoological Scientific Name
            function prettifyEnum(text) {
                if (typeof text === 'undefined') {
                    return '';
                }
                return text.replace(/([A-Z])/g, ' $1');
            }

            //rewrite annotation link and add tracking to see how many people use it
            var linkToGbifApiFromAnnosys = '${action.cfg.apiBaseUrl}occurrence/annosys/${id?c}<#if (tab!)=="verbatim">/verbatim</#if>';
            $('#annosysModal .annosys__annotate').prop('href', '${cfg.annosysUrl}AnnoSys?recordURL=' + linkToGbifApiFromAnnosys);
            $('#annosysModal .annosys__annotate').on('click', function(event) {
                if (typeof ga !== 'undefined') {
                    ga('send', 'event', 'annotation', 'followed');
                }
            });
            if (typeof ga !== 'undefined') {
                ga('send', 'event', 'annotation', 'seen');
            }

            // for the given record load the annotations
            // the record must have an institutionCode, collectionCode and catalogNumber or else none will be found
            function loadAnnotations(record) {
                var record = {};
                record.institutionCode = '${institutionCode}';
                record.collectionCode = '${collectionCode}';
                record.catalogNumber = '${catalogNumber}';

                if (record.institutionCode && record.collectionCode && record.catalogNumber) {

                    var url = "${cfg.annosysUrl}services/records/" +
                            encodeURIComponent(record.institutionCode) + "/" + encodeURIComponent(record.collectionCode) + "/" + encodeURIComponent(record.catalogNumber)
                            + "/annotations";

                    $.getJSON(url, function (data) {
                        //sort annotations by date, newest first
                        data.annotations = data.annotations.sort(function (a, b) {
                            if (a.time < b.time) {
                                return 1;
                            }
                            if (a.time > b.time) {
                                return -1;
                            }
                            return 0;
                        });

                        $.each(data.annotations, function (index, annotation) {
                            var editDate = new Date(annotation.time);
                            var annosysLink = '${cfg.annosysUrl}AnnoSys?repositoryURI=' + annotation.repositoryURI;
                            $("#annotations").append('<li><a target="_blank" href="'+annosysLink+'"><span class="annosys__motivation">' + prettifyEnum(annotation.motivation) + '</span><span class="annosys__annotator">' + annotation.annotator + '</span><span class="annosys__date">' + editDate.toDateString() + '</span></a></li>');
                        });
                        if (data.annotations.length > 0) {
                            $('#annosysModal .existingAnnotations').show();
                            $('#annosysTrigger span').html(data.annotations.length);
                            $('#annosysTrigger span').show();
                        }
                    }).fail(function (jqxhr, textStatus, error) {
                        //No annotations found
                    });
                }
            }

            //annosys modal handling
            function closeAnnosysModal(e) {
                $('#annosysBlanket').hide();
                $('#annosysModal').hide();
                $('body').removeClass('u-overflowHidden');
                e.preventDefault();
            }

            $('#annosysTrigger').on('click', function (e) {
                $('#annosysBlanket').show();
                $('#annosysModal').show();
                $('body').addClass('u-overflowHidden');
                e.preventDefault();
            });
            $('#annosysBlanket').on('click', closeAnnosysModal);
            $('#annosysModal .cancel').on('click', closeAnnosysModal);
            loadAnnotations();
        });
    </script>

</#if>