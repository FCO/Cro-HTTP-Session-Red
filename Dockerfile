FROM    fernandocorrea/red-tester
RUN     git clone https://github.com/FCO/Red.git && zef install --/test --force-install ./Red
RUN     apk add --update make libressl-dev && zef install --/test --force-install cro
