# -*- coding: utf-8 -*-

module Rut::Copy
  [:None,
   :Overwrite,
   :Backup,
   :DoNotFollowSymlinks,
   :AllMetadata,
   :NoFallbackForMove,
   :TargetDefaultPermissions].each_with_index do |name, index|
    const_set name, 1 << index - 1
   end
end
