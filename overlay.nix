self: super:

{
  drpcli = self.callPackage (import ./pkgs/tools/admin/drpcli) {};
}
