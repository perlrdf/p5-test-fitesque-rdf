use Test::Perl::Critic(-exclude => [
												'RequireFinalReturn',
											   'ProhibitUnusedPrivateSubroutines',
											   'RequireExtendedFormatting',
											   'ProhibitExcessComplexity',
												'ProhibitDeepNests',
												'RequireExplicitPackage'
											  ],
							  -severity => 3);
all_critic_ok();
