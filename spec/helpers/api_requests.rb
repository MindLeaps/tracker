# frozen_string_literal: true
module Helpers
  def get_with_token(*args)
    get(*merge_auth_headers(args))
  end

  def post_with_token(*args)
    post(*merge_auth_headers(args))
  end

  def patch_with_token(*args)
    patch(*merge_auth_headers(args))
  end

  def delete_with_token(*args)
    delete(*merge_auth_headers(args))
  end

  def merge_auth_headers(args)
    if args.length > 1
      if args[1][:headers]
        args[1][:headers].merge! auth_headers
      else
        args[1][:headers] = auth_headers
      end
    else
      args << auth_headers
    end
    args
  end

  def auth_headers
    { 'X-USER-EMAIL': @current_user.email, 'X-USER-TOKEN': @token }
  end
end
