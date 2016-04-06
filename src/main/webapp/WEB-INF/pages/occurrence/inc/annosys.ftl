<#-- Annosys modal and button but only if it is from the publisher http://www.bgbm.org -->
    <#assign institutionCode = action.termValue('institutionCode')! />
    <#assign collectionCode = action.termValue('collectionCode')! />
    <#assign catalogNumber =  action.termValue('catalogNumber')! />
    <#assign occurrenceID =  action.termValue('occurrenceID')! />
    <#assign publishingOrgKey =  action.termValue('publishingOrgKey')! />

<#if publisher.key=="57254bd0-8256-11d8-b7ed-b8a03c50a862">
    <style type="text/css">
        /*Annosys only*/
        .annosys {
            left: 100%;
            top: calc(40% + 100px);
            -webkit-transform-origin: top left;
            -webkit-transform: rotate(90deg);
            -moz-transform: rotate(90deg);
            -moz-transform-origin: top left;
            -ms-transform: rotate(90deg);
            -ms-transform-origin: top left;
            z-index: 10001;
            position: fixed;
            background: #013466;
            padding: 5px;
            border: 2px solid white;
            border-top: none;
            font-weight: bold;
            color: white !important;
            display: block;
            white-space: nowrap;
            text-decoration: none !important;
            font-family: arial, FreeSans, Helvetica, sans-serif;
            font-size: 12px;
            box-shadow: 5px 5px 10px rgba(0, 0, 0, 0.5);
            -webkit-box-shadow: 5px 5px 10px rgba(0, 0, 0, 0.5);
            -moz-box-shadow: 5px 5px 10px rgba(0, 0, 0, 0.5);
            border-radius: 0 0 5px 5px;
            -moz-border-radius: 0 0 5px 5px;
        }

        .annosys > span {
            background: tomato;
            border-radius: 2px;
            padding: 0 5px;
            margin-left: 2px;
            display: none;
        }

        .annosysBlanket {
            display: none;
        }

        #annosysModal {
            width: 810px;
            max-width: 100%;
            right: calc(50% - 405px);
            background: white;
            border: 1px solid #666;
            position: fixed;
            top: 20%;
            z-index: 10000011;
            text-align: left;
            display: none;
        }
        @media (max-height: 600px) {
            #annosysModal {
                top: 5%;
            }
        }

        #annosysModal h2 {
            font-size: 21px;
            padding: 15px 20px;
            background: #f0f0f0;
            color: #666;
            margin: 0;
            overflow: hidden;
            border-bottom: 1px solid #cccccc;
            -moz-box-sizing: border-box;
            box-sizing: border-box;
            line-height: 1.5;
            font-weight: normal;
            text-align: left;
        }

        #annosysModal footer {
            background-color: #f5f5f5;
            border-top: 1px solid #ccc;
            clear: both;
            overflow: hidden;
            padding: 10px;
            text-align: right;
        }

        #annosysModal footer .cancel {
            cursor: pointer;
            font-size: 14px;
            display: inline-block;
            padding: 5px 10px;
            vertical-align: baseline;
            color: #326ca6;
            text-decoration: none;
        }

        #annosysModal footer .cancel:hover {
            text-decoration: underline;
        }

        #annosysModal footer .button {
            background: #f2f2f2;
            background: linear-gradient(to bottom, #ffffff 0%, #f2f2f2 100%);
            -moz-box-sizing: border-box;
            box-sizing: border-box;
            border: 1px solid #cccccc;
            border-radius: 3.01px;
            color: #333333;
            cursor: pointer;
            display: inline-block;
            font-family: Arial, sans-serif;
            font-size: 14px;
            font-variant: normal;
            font-weight: normal;
            height: 2.1428571428571em;
            line-height: 1.4285714285714;
            margin: 0;
            padding: 4px 10px;
            text-decoration: none;
            text-shadow: 0 1px 0 white;
            vertical-align: baseline;
            white-space: nowrap;
        }

        #annosysModal footer .button:hover {
            border-color: #999999;
        }

        #annosysModal .annosysModal__content {
            max-height: 450px;
            overflow: auto;
            padding: 20px;
            font-size: 14px;
        }

        #annosysModal .annosysModal__content img {
            width: 150px;
            margin: auto;
            max-width: 100%;
            display: block;
            float: right;
            padding: 0 10px;
        }

        #annosysModal .annosysModal__content h3 {
            font-weight: bold;
            margin-bottom: 1.5em;
        }

        #annosysModal .annosysModal__content p {
            padding-bottom: 1.5em;
        }

        #annosysModal .existingAnnotations {
            display: none;
        }

        #annosysModal .annosys__date {
            color: #ccc;
            margin-left: 5px;
        }
        #annosysModal .existingAnnotations a {
            color: #333;
        }
        #annosysModal .existingAnnotations .annosys__motivation {
            color: #0099cc;
            margin-right: 5px;
        }

        body.u-overflowHidden {
            overflow: hidden;
        }
    </style>

    <a id="annosysTrigger" href="#" class="annosys">AnnoSys <span class="annosysCount"></span></a>
    <div id="annosysBlanket" class="atlwdg-blanket annosysBlanket"></div>
    <div id="annosysModal" class="atlwdg-box-shadow annosysModal">
        <h2>Annosys</h2>
        <div class="annosysModal__content">
            <img src="//annosys.bgbm.fu-berlin.de/sites/default/files/AnnoSys_update.png">
            <p>
                Annosys is an annotation system that allows you to correct records. Tim fill this in.
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
        $(window).load(function () {

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
                    ga('send', 'event', 'occurrence', 'annotate');
                }
            });

            // for the given record load the annotations
            // the record must have an institutionCode, collectionCode and catalogNumber or else none will be found
            function loadAnnotations(record) {
                var record = {};
                record.institutionCode = '${institutionCode}';
                record.collectionCode = '${collectionCode}';
                record.catalogNumber = '${catalogNumber}';
                record.occurrenceID = '${occurrenceID}';

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