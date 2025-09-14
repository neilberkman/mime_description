defmodule MimeDescriptionTest do
  use ExUnit.Case

  describe "get/1" do
    test "returns {:ok, description} for known MIME types" do
      assert {:ok, "PDF document"} = MimeDescription.get("application/pdf")
      assert {:ok, "Plain text document"} = MimeDescription.get("text/plain")
      assert {:ok, "HTML document"} = MimeDescription.get("text/html")
      assert {:ok, "JPEG image"} = MimeDescription.get("image/jpeg")
      assert {:ok, "PNG image"} = MimeDescription.get("image/png")
    end

    test "returns {:error, :not_found} for unknown MIME type" do
      assert {:error, :not_found} = MimeDescription.get("unknown/unknown")
      assert {:error, :not_found} = MimeDescription.get("fake/mimetype")
    end

    test "handles edge cases" do
      assert {:error, :not_found} = MimeDescription.get("")
      assert {:error, :not_found} = MimeDescription.get("not-a-mime-type")
    end
  end

  describe "get_from_header/1" do
    test "extracts MIME type from header with charset" do
      assert {:ok, "Plain text document"} = MimeDescription.get_from_header("text/plain; charset=utf-8")
      assert {:ok, "HTML document"} = MimeDescription.get_from_header("text/html; charset=ISO-8859-1")
      assert {:ok, "JSON document"} = MimeDescription.get_from_header("application/json; charset=utf-8")
    end

    test "handles headers without spaces" do
      assert {:ok, "PDF document"} = MimeDescription.get_from_header("application/pdf;name=document.pdf")
      assert {:ok, "Plain text document"} = MimeDescription.get_from_header("text/plain;charset=utf-8")
    end

    test "handles headers with multiple parameters" do
      assert {:ok, "Plain text document"} = 
        MimeDescription.get_from_header("text/plain; charset=utf-8; format=flowed")
      
      assert {:ok, "Compound documents"} = 
        MimeDescription.get_from_header("multipart/mixed; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW")
    end

    test "handles headers with extra whitespace" do
      assert {:ok, "HTML document"} = MimeDescription.get_from_header("  text/html ; charset=ISO-8859-1  ")
      assert {:ok, "PDF document"} = MimeDescription.get_from_header(" application/pdf ")
    end

    test "returns error for unknown MIME types with parameters" do
      assert {:error, :not_found} = MimeDescription.get_from_header("unknown/type; param=value")
      assert {:error, :not_found} = MimeDescription.get_from_header("application/x-custom; charset=utf-8")
    end

    test "handles uppercase MIME types" do
      assert {:ok, "PDF document"} = MimeDescription.get_from_header("APPLICATION/PDF; name=test")
      assert {:ok, "Plain text document"} = MimeDescription.get_from_header("TEXT/PLAIN")
    end
  end

  describe "get_from_header_with_fallback/2" do
    test "returns description for known MIME types" do
      assert "Plain text document" = MimeDescription.get_from_header_with_fallback("text/plain; charset=utf-8")
      assert "PDF document" = MimeDescription.get_from_header_with_fallback("application/pdf")
    end

    test "returns cleaned MIME type as fallback for unknown types" do
      assert "application/x-custom" = 
        MimeDescription.get_from_header_with_fallback("application/x-custom; param=value")
      
      assert "unknown/type" = 
        MimeDescription.get_from_header_with_fallback("unknown/type; charset=utf-8")
    end

    test "uses custom default when provided" do
      assert "Unknown file" = 
        MimeDescription.get_from_header_with_fallback("unknown/type; charset=utf-8", "Unknown file")
      
      assert "Custom fallback" = 
        MimeDescription.get_from_header_with_fallback("fake/mime", "Custom fallback")
    end

    test "handles empty or invalid input" do
      assert "" = MimeDescription.get_from_header_with_fallback("")
      assert "" = MimeDescription.get_from_header_with_fallback(";charset=utf-8")
    end
  end

  describe "extract_mime_type/1" do
    test "extracts base MIME type from headers with parameters" do
      assert "text/plain" = MimeDescription.extract_mime_type("text/plain; charset=utf-8")
      assert "application/pdf" = MimeDescription.extract_mime_type("application/pdf;name=document.pdf")
      assert "text/html" = MimeDescription.extract_mime_type("text/html ; charset=ISO-8859-1")
    end

    test "handles headers without parameters" do
      assert "application/json" = MimeDescription.extract_mime_type("application/json")
      assert "image/png" = MimeDescription.extract_mime_type("image/png")
    end

    test "trims whitespace and converts to lowercase" do
      assert "text/plain" = MimeDescription.extract_mime_type("  TEXT/PLAIN  ")
      assert "application/pdf" = MimeDescription.extract_mime_type(" Application/PDF ; name=test")
    end

    test "handles empty input" do
      assert "" = MimeDescription.extract_mime_type("")
      assert "" = MimeDescription.extract_mime_type(";charset=utf-8")
    end

    test "handles multiple semicolons" do
      assert "text/plain" = MimeDescription.extract_mime_type("text/plain; charset=utf-8; format=flowed; delsp=yes")
    end
  end

  describe "get!/1" do
    test "returns description for known MIME types" do
      assert "PDF document" = MimeDescription.get!("application/pdf")
      assert "Plain text document" = MimeDescription.get!("text/plain")
    end

    test "raises KeyError for unknown MIME type" do
      assert_raise KeyError, ~r/MIME type not found: "unknown\/unknown"/, fn ->
        MimeDescription.get!("unknown/unknown")
      end
    end
  end

  describe "get_with_default/2" do
    test "returns description for known MIME types" do
      assert "PDF document" = MimeDescription.get_with_default("application/pdf")
      assert "Plain text document" = MimeDescription.get_with_default("text/plain", "fallback")
    end

    test "returns default for unknown MIME type" do
      assert "Unknown file type" = MimeDescription.get_with_default("unknown/unknown")
      assert "Custom fallback" = MimeDescription.get_with_default("unknown/unknown", "Custom fallback")
    end

    test "default parameter works correctly" do
      assert "Custom" = MimeDescription.get_with_default("fake/type", "Custom")
      assert "Unknown file type" = MimeDescription.get_with_default("fake/type")
    end
  end

  describe "data integrity" do
    test "data module exists and returns map" do
      assert is_map(MimeDescription.Data.get_all())
    end

    test "data module contains expected MIME types" do
      data = MimeDescription.Data.get_all()
      
      # Check for common MIME types
      assert Map.has_key?(data, "application/pdf")
      assert Map.has_key?(data, "text/plain")
      assert Map.has_key?(data, "text/html")
      assert Map.has_key?(data, "image/jpeg")
      assert Map.has_key?(data, "image/png")
      assert Map.has_key?(data, "application/json")
      assert Map.has_key?(data, "application/xml")
      assert Map.has_key?(data, "multipart/mixed")
      assert Map.has_key?(data, "multipart/alternative")
    end

    test "all descriptions are non-empty strings" do
      data = MimeDescription.Data.get_all()
      
      Enum.each(data, fn {mime_type, description} ->
        assert is_binary(mime_type)
        assert is_binary(description)
        assert String.length(description) > 0
        refute String.contains?(mime_type, " ")
      end)
    end
  end

  describe "real-world email headers" do
    test "handles various Content-Type headers from emails" do
      # Common email headers
      assert {:ok, "Plain text document"} = 
        MimeDescription.get_from_header("text/plain; charset=\"UTF-8\"")
      
      assert {:ok, "HTML document"} = 
        MimeDescription.get_from_header("text/html; charset=\"iso-8859-1\"")
      
      assert {:ok, "Message in several formats"} = 
        MimeDescription.get_from_header("multipart/alternative; boundary=\"000000000000a1b2c3d4e5f6\"")
      
      assert {:ok, "Compound documents"} = 
        MimeDescription.get_from_header("multipart/mixed; boundary=\"----=_Part_123456_789.012345\"")
      
      assert {:ok, "PDF document"} = 
        MimeDescription.get_from_header("application/pdf; name=\"invoice.pdf\"")
      
      assert {:ok, "Word document"} = 
        MimeDescription.get_from_header("application/msword; name=\"document.doc\"")
      
      assert {:ok, "PNG image"} = 
        MimeDescription.get_from_header("image/png; name=\"screenshot.png\"")
    end

    test "handles complex multipart boundaries" do
      assert {:ok, "Compound document"} = 
        MimeDescription.get_from_header("multipart/related; boundary=\"----=_NextPart_001_0026_01CA4D77.52F7D850\"; type=\"text/html\"")
    end
  end
end