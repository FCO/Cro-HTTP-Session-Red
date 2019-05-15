FROM    fernandocorrea/red-tester
RUN     zef install --/test --force-install Red
RUN     zef install --/test --force-install cro
