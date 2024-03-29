module Helpers
  def get_v2_with_token(*args)
    get_with_token(*merge_version_header(args))
  end

  def post_v2_with_token(*args)
    post_with_token(*merge_version_header(args))
  end

  def put_v2_with_token(*args)
    put_with_token(*merge_version_header(args))
  end

  def patch_v2_with_token(*args)
    patch_with_token(*merge_version_header(args))
  end

  def delete_v2_with_token(*args)
    delete_with_token(*merge_version_header(args))
  end

  def get_with_token(*args)
    merged_args = merge_auth_headers args
    get(merged_args[0], **merged_args[1])
  end

  def post_with_token(*args)
    merged_args = merge_auth_headers args
    post(merged_args[0], **merged_args[1])
  end

  def put_with_token(*args)
    merged_args = merge_auth_headers args
    put(merged_args[0], **merged_args[1])
  end

  def patch_with_token(*args)
    merged_args = merge_auth_headers args
    patch(merged_args[0], **merged_args[1])
  end

  def delete_with_token(*args)
    merged_args = merge_auth_headers args
    delete(merged_args[0], **merged_args[1])
  end

  def merge_auth_headers(args)
    merge_headers auth_headers, args
  end

  def merge_version_header(args)
    merge_headers version_2_header, args
  end

  def merge_headers(headers_to_merge, args)
    if args.length > 1
      if args[1][:headers]
        args[1][:headers].merge! headers_to_merge
      else
        args[1][:headers] = headers_to_merge
      end
    else
      args << headers_to_merge
    end
    args
  end

  def version_2_header
    { Accept: 'application/json; version=2' }
  end

  def auth_headers
    { 'X-USER-EMAIL': @current_user.email, 'X-USER-TOKEN': @token }
  end
end
