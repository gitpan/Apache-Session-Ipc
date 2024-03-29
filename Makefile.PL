use 5.008004;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Apache::Session::Ipc',
    VERSION_FROM      => 'lib/Apache/Session/Ipc.pm', # finds $VERSION
    PREREQ_PM         => { 'Apache::Session' => 0, 'IPC::Shareable' => 0, 'Time::HiRes' => 0 },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Apache/Session/Ipc.pm', # retrieve abstract from module
       AUTHOR         => 'Xavier Guimard <guimard@>') : ()),
);
