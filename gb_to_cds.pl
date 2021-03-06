#!/usr/bin/env perl
use strict;
use Bio::SeqIO;
# requires BioPerl: http://search.cpan.org/~cjfields/BioPerl/

my $infile = shift;

unless($infile) {
    die "Usage: $0 [Genbank file]\n";
}

my $objseqio = Bio::SeqIO->new(-file => $infile);
while(my $objseq = $objseqio->next_seq) {
    
    my $acc = $objseq->accession_number;
    my @cds_features = grep { $_->primary_tag eq 'CDS' } $objseq->get_SeqFeatures;
    
    foreach my $objfeat (@cds_features) {
        unless($objfeat->has_tag('pseudo')) {
            my ($protid, @others) = $objfeat->get_tag_values('protein_id');
            my ($prod_ann) = $objfeat->get_tag_values('product');
            my ($locus, @others);
        
            if($objfeat->has_tag('gene')) {
                ($locus, @others) = $objfeat->get_tag_values('gene');
                if(scalar(@others) > 0) {
                    print STDERR "Multiple gene values for CDS on $acc\n";
                }
            } elsif($objfeat->has_tag('locus_tag')) {
                ($locus, @others) = $objfeat->get_tag_values('locus_tag');
                if(scalar(@others) > 0) {
                    print STDERR "Multiple locus_tag values for CDS on $acc\n";
                }
            }
        
            if(length($locus) > 0) {
                printf ">%s %s %s\n", $locus, $protid, $prod_ann;
                print $objfeat->spliced_seq->seq."\n";
            } else {
                print STDERR "No gene/locus_tag found for CDS on $acc\n";
            }
        }
    }
}
