#!/usr/bin/perl -w
use warnings;
use strict;

# Votebot: A simple polling bot for IRC channels
# Copyright (C) 2014 Chris Wallace (notori0us) <chris@chriswallace.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

package VoteBot;
use base qw( Bot::BasicBot );

# CONFIGURIGATION
# --------------------------------------------------

# details
my $nick = "osousc_votebot";
my $server = "chat.freenode.net";
# please only use the one channel.
my @channels = ['#osuosc'];
my $channel = $channels[0];
# 

# CODE
# --------------------------------------------------

my $poll = 0;
my @choices = [];
my @votes = [];
my $options = 0;

# override the said
sub said {
	my ($self, $message) = @_;

	if ($message->{body} =~ /^\.startpoll\b/) {
		if ($poll) {
			$self->say(
				channel => $channel,
				body => "There is already a poll!",
			);
		}
		else {

			my $title = $message->{body};
			$title =~ s/^\.startpoll\ //;

			$poll = $title;
			$options = $title;


			$self->say(
				channel => $channel,
				body => "Poll \"" . $poll . "\" started.",
			);
		}
	}
	elsif ($message->{body} =~ /^\.endpoll\b/) {
		if ($poll) {
			$self->say(
				channel => $channel,
				body => "Poll \"" . $poll . "\" ended.",
			);

			my $count = 0;

			foreach (@choices) {
				if ($count == 0) {
					$count = $count + 1;
					next;
				}

				$self->say(
					channel => $channel,
					body => $count . ". " . $_ . ": " . $votes[$count],
				);
				$count = $count + 1;
			}


			#print_results;
			$poll = 0;
			@choices = [];
			@votes = [];
		}
		else {
			$self->say(
				channel => $channel,
				body => "There is not a poll to end.",
			);
		}
	}
	elsif ($message->{body} =~ /^\.lockoptions\b/) {
		$options = 0;
	}
	elsif ($message->{body} =~ /^\.addoption\b/) {
		if ($poll && $options) {
			my $option = $message->{body};
			$option =~ s/^\.addoption\ //;
			push(@choices, $option);
			push(@votes, 0);
			$self->say(
				channel => $channel,
				body => "Option \"" . $option . "\" added.",
			);
		}
	}
	elsif ($message->{body} =~ /^.vote\b/) {
		sub isint{
			my $val = shift;
			return ($val =~ m/^\d+$/);
		}

		if ($poll) {
			my $option = $message->{body};
			$option =~ s/^\.vote\ //;

			if (isint($option) && $option > 0 && $option < @votes) {
				$votes[$option] = $votes[$option] + 1;
				$self->say(
					channel => $channel,
					body => "Vote recorded for option " . $choices[$option],
				);
			}
			else {
				$self->say(
					channel => $channel,
					body => "Invalid vote",
				);
			}

		}
	}
	elsif ($message->{body} =~ /^.showpoll\b/) {
		if ($poll) {
			my $count = 0;
			my $str = "";
			foreach (@choices) {
				if ($count == 0) {
					$count = $count + 1;
					next;
				}

				$str = $str . $count . ". " . $_ . ": " . $votes[$count] . " | ";

				$count = $count + 1;
			}

			$self->say(
				channel => $channel,
				body => $str,
			);
		}
	}

}

# GO
# --------------------------------------------------

VoteBot->new(
	server => $server,
	channels => @channels,
	nick => $nick,
)->run();
