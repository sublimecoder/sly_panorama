defmodule SlyPanorama.BookingEmail do
  alias SlyPanorama.Mailer
  import Swoosh.Email

  @from {"Sly Panorama booking", "no-reply@slypanorama.com"}
  @to "booking@slypanorama.com"

  def send_booking_email(booking, services) do
    IO.inspect("Draft Booking Email")
    text = """
        New booking request from #{booking["name"]}.

        Name: #{booking["name"]}
        Email: #{booking["email"]}
        Phone: #{booking["phone"]}
        Instagram: #{booking["instagram"]}
        X: #{booking["x"]}
        Website: #{booking["website"]}
        Date: #{booking["date"]}
        Type: #{booking["type"]}
        Scene description:
    #{booking["scene_description"]}
    ---------
        Scene content requested:
    #{Enum.join(services, ", ")}

    """

    html = """
            <div style="font-family: Arial, sans-serif; line-height: 1.5; color: #333;">
              <h2 style="color:#444;">New booking request from #{booking["name"]}</h2>

              <p><strong>Name:</strong> #{booking["name"]}</p>
              <p><strong>Email:</strong> #{booking["email"]}</p>
              <p><strong>Phone:</strong> #{booking["phone"]}</p>
              <p><strong>Instagram:</strong> #{booking["instagram"]}</p>
              <p><strong>X:</strong> #{booking["x"]}</p>
              <p><strong>Website:</strong> #{booking["website"]}</p>
              <p><strong>Date:</strong> #{booking["date"]}</p>
              <p><strong>Type:</strong> #{booking["type"]}</p>

              <h3 style="margin-top:20px; color:#444;">Scene description</h3>
              <p style="white-space: pre-line;">#{booking["scene_description"]}</p>

              <h3 style="margin-top:20px; color:#444;">Scene content requested</h3>
              <p>#{Enum.join(services, ", ")}</p>
            </div>

            """

    email =
      new()
      |> to(@to)
      |> from(@from)
      |> subject("New booking request from #{booking["name"]}")
      |> text_body(text)
      |> html_body(html)

    Mailer.deliver(email)

    IO.inspect("Booking Email Delivered")
  end
end
